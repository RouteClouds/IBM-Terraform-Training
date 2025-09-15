/**
 * IBM Cloud Functions - Drift Detection Function
 * Subtopic 6.2: State Locking and Drift Detection
 * Automated drift detection and alerting for Terraform infrastructure
 */

const { exec } = require('child_process');
const https = require('https');
const http = require('http');

/**
 * Main function entry point for IBM Cloud Functions
 * @param {Object} params - Function parameters
 * @returns {Object} Function response
 */
async function main(params) {
    console.log('Drift detection function started');
    console.log('Parameters:', JSON.stringify(params, null, 2));
    
    try {
        // Extract parameters
        const {
            terraform_workspace = '/tmp/terraform',
            severity_threshold = 3,
            auto_remediation = false,
            slack_webhook = '',
            email_recipients = [],
            workspace_path = '/tmp/terraform',
            project_name = 'unknown'
        } = params;
        
        // Execute drift detection
        const driftResult = await detectDrift(workspace_path);
        
        // Analyze drift severity
        const severity = analyzeDriftSeverity(driftResult.output);
        
        console.log(`Drift detection completed. Severity: ${severity}`);
        
        // Handle drift based on severity
        if (driftResult.driftDetected) {
            console.log('Drift detected, processing alerts and remediation');
            
            // Send alerts
            await sendAlerts({
                driftResult,
                severity,
                severity_threshold,
                slack_webhook,
                email_recipients,
                project_name
            });
            
            // Handle remediation
            const remediationResult = await handleRemediation({
                driftResult,
                severity,
                auto_remediation,
                severity_threshold
            });
            
            return {
                statusCode: 200,
                body: {
                    message: 'Drift detected and processed',
                    drift: true,
                    severity: severity,
                    remediation: remediationResult,
                    timestamp: new Date().toISOString()
                }
            };
        } else {
            console.log('No drift detected');
            return {
                statusCode: 200,
                body: {
                    message: 'No drift detected',
                    drift: false,
                    timestamp: new Date().toISOString()
                }
            };
        }
        
    } catch (error) {
        console.error('Drift detection function error:', error);
        return {
            statusCode: 500,
            body: {
                error: error.message,
                timestamp: new Date().toISOString()
            }
        };
    }
}

/**
 * Execute terraform plan to detect drift
 * @param {string} workspacePath - Path to Terraform workspace
 * @returns {Object} Drift detection result
 */
function detectDrift(workspacePath) {
    return new Promise((resolve, reject) => {
        console.log(`Executing terraform plan in ${workspacePath}`);
        
        // Execute terraform plan with detailed exit code
        exec('terraform plan -detailed-exitcode -no-color', 
             { cwd: workspacePath, timeout: 300000 }, 
             (error, stdout, stderr) => {
                 const output = stdout + stderr;
                 console.log('Terraform plan output:', output);
                 
                 if (error) {
                     // Exit code 2 means changes detected (drift)
                     if (error.code === 2) {
                         resolve({
                             driftDetected: true,
                             exitCode: 2,
                             output: output,
                             changes: parseTerraformChanges(output)
                         });
                     } else {
                         // Other exit codes indicate errors
                         reject(new Error(`Terraform plan failed: ${error.message}`));
                     }
                 } else {
                     // Exit code 0 means no changes (no drift)
                     resolve({
                         driftDetected: false,
                         exitCode: 0,
                         output: output,
                         changes: []
                     });
                 }
             });
    });
}

/**
 * Parse Terraform plan output to extract changes
 * @param {string} planOutput - Terraform plan output
 * @returns {Array} Array of detected changes
 */
function parseTerraformChanges(planOutput) {
    const changes = [];
    const lines = planOutput.split('\n');
    
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i].trim();
        
        // Detect resource changes
        if (line.match(/^[~+-] resource/)) {
            const action = line.charAt(0);
            const resourceMatch = line.match(/resource "([^"]+)" "([^"]+)"/);
            
            if (resourceMatch) {
                changes.push({
                    action: getActionType(action),
                    resourceType: resourceMatch[1],
                    resourceName: resourceMatch[2],
                    line: line
                });
            }
        }
    }
    
    return changes;
}

/**
 * Convert Terraform action symbol to readable action type
 * @param {string} symbol - Terraform action symbol
 * @returns {string} Action type
 */
function getActionType(symbol) {
    switch (symbol) {
        case '+': return 'create';
        case '-': return 'destroy';
        case '~': return 'update';
        default: return 'unknown';
    }
}

/**
 * Analyze drift severity based on changes detected
 * @param {string} planOutput - Terraform plan output
 * @returns {number} Severity score (1-10)
 */
function analyzeDriftSeverity(planOutput) {
    let severity = 1;
    
    // Increase severity based on resource types and actions
    if (planOutput.includes('security_group')) severity += 3;
    if (planOutput.includes('destroy')) severity += 5;
    if (planOutput.includes('database')) severity += 4;
    if (planOutput.includes('vpc')) severity += 2;
    if (planOutput.includes('subnet')) severity += 2;
    if (planOutput.includes('instance')) severity += 3;
    if (planOutput.includes('key_protect')) severity += 4;
    if (planOutput.includes('certificate')) severity += 3;
    
    // Count number of resources affected
    const resourceCount = (planOutput.match(/resource "/g) || []).length;
    severity += Math.min(resourceCount, 3);
    
    return Math.min(severity, 10);
}

/**
 * Send alerts for detected drift
 * @param {Object} alertParams - Alert parameters
 */
async function sendAlerts(alertParams) {
    const {
        driftResult,
        severity,
        severity_threshold,
        slack_webhook,
        email_recipients,
        project_name
    } = alertParams;
    
    // Only send alerts if severity exceeds threshold
    if (severity < severity_threshold) {
        console.log(`Severity ${severity} below threshold ${severity_threshold}, skipping alerts`);
        return;
    }
    
    const alertMessage = {
        project: project_name,
        severity: severity,
        timestamp: new Date().toISOString(),
        changes: driftResult.changes,
        summary: `${driftResult.changes.length} infrastructure changes detected`
    };
    
    // Send Slack notification
    if (slack_webhook) {
        try {
            await sendSlackAlert(slack_webhook, alertMessage);
            console.log('Slack alert sent successfully');
        } catch (error) {
            console.error('Failed to send Slack alert:', error);
        }
    }
    
    // Send email notifications
    if (email_recipients && email_recipients.length > 0) {
        try {
            await sendEmailAlerts(email_recipients, alertMessage);
            console.log('Email alerts sent successfully');
        } catch (error) {
            console.error('Failed to send email alerts:', error);
        }
    }
}

/**
 * Send Slack notification
 * @param {string} webhookUrl - Slack webhook URL
 * @param {Object} alertMessage - Alert message data
 */
function sendSlackAlert(webhookUrl, alertMessage) {
    return new Promise((resolve, reject) => {
        const payload = {
            text: "🚨 Infrastructure Drift Detected",
            attachments: [{
                color: alertMessage.severity >= 7 ? "danger" : 
                       alertMessage.severity >= 4 ? "warning" : "good",
                fields: [
                    {
                        title: "Project",
                        value: alertMessage.project,
                        short: true
                    },
                    {
                        title: "Severity",
                        value: `${alertMessage.severity}/10`,
                        short: true
                    },
                    {
                        title: "Changes Detected",
                        value: alertMessage.summary,
                        short: false
                    },
                    {
                        title: "Timestamp",
                        value: alertMessage.timestamp,
                        short: true
                    }
                ]
            }]
        };
        
        const postData = JSON.stringify(payload);
        const url = new URL(webhookUrl);
        
        const options = {
            hostname: url.hostname,
            port: url.port || 443,
            path: url.pathname,
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': Buffer.byteLength(postData)
            }
        };
        
        const req = https.request(options, (res) => {
            if (res.statusCode >= 200 && res.statusCode < 300) {
                resolve();
            } else {
                reject(new Error(`Slack webhook returned status ${res.statusCode}`));
            }
        });
        
        req.on('error', reject);
        req.write(postData);
        req.end();
    });
}

/**
 * Send email alerts (placeholder implementation)
 * @param {Array} recipients - Email recipients
 * @param {Object} alertMessage - Alert message data
 */
async function sendEmailAlerts(recipients, alertMessage) {
    // In a real implementation, this would integrate with IBM Cloud Email Service
    // or another email provider
    console.log('Email alert would be sent to:', recipients);
    console.log('Alert message:', alertMessage);
    
    // Placeholder for email sending logic
    return Promise.resolve();
}

/**
 * Handle drift remediation based on severity and configuration
 * @param {Object} remediationParams - Remediation parameters
 * @returns {Object} Remediation result
 */
async function handleRemediation(remediationParams) {
    const {
        driftResult,
        severity,
        auto_remediation,
        severity_threshold
    } = remediationParams;
    
    if (!auto_remediation) {
        return {
            action: 'manual_review_required',
            reason: 'Auto-remediation disabled'
        };
    }
    
    if (severity > severity_threshold) {
        return {
            action: 'approval_required',
            reason: `Severity ${severity} exceeds auto-remediation threshold ${severity_threshold}`
        };
    }
    
    // For low-severity drift, attempt auto-remediation
    try {
        console.log('Attempting auto-remediation for low-severity drift');
        
        // In a real implementation, this would execute terraform apply
        // For safety, we'll just log the action
        console.log('Auto-remediation would execute: terraform apply -auto-approve');
        
        return {
            action: 'auto_remediated',
            timestamp: new Date().toISOString(),
            changes_applied: driftResult.changes.length
        };
        
    } catch (error) {
        console.error('Auto-remediation failed:', error);
        return {
            action: 'remediation_failed',
            error: error.message
        };
    }
}

// Export the main function for IBM Cloud Functions
exports.main = main;
