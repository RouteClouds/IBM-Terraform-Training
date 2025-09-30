/**
 * Just-in-Time (JIT) Access Request Function
 * Topic 7.2: Identity and Access Management (IAM) Integration
 * 
 * This function handles privileged access requests with automated approval workflows,
 * risk assessment, and temporary privilege elevation.
 */

const { IamAccessGroupsV2 } = require('@ibm-cloud/platform-services');
const { IamIdentityV1 } = require('@ibm-cloud/platform-services');

/**
 * Main function handler for JIT access requests
 * @param {Object} params - Function parameters
 * @param {string} params.action - Action to perform: 'request', 'approve', 'revoke'
 * @param {Object} params.user - User requesting access
 * @param {string} params.justification - Business justification for access
 * @param {number} params.duration - Requested duration in hours
 * @param {Object} params.approver - Approving manager (for approve action)
 * @returns {Object} Response with action result
 */
exports.main = async function(params) {
    const { action, user, justification, duration, approver } = params;
    
    // Configuration from template variables
    const maxDurationHours = ${max_duration_hours};
    const approvalRequired = ${approval_required};
    
    try {
        // Initialize IBM Cloud SDK clients
        const iamAccessGroups = IamAccessGroupsV2.newInstance({
            authenticator: new IamAuthenticator({
                apikey: process.env.IAM_API_KEY
            })
        });
        
        const iamIdentity = IamIdentityV1.newInstance({
            authenticator: new IamAuthenticator({
                apikey: process.env.IAM_API_KEY
            })
        });
        
        switch (action) {
            case 'request':
                return await handleAccessRequest(user, justification, duration, maxDurationHours, approvalRequired);
            case 'approve':
                return await handleAccessApproval(iamAccessGroups, user, approver);
            case 'revoke':
                return await handleAccessRevocation(iamAccessGroups, user);
            default:
                throw new Error(`Unknown action: $${action}`);
        }
    } catch (error) {
        console.error('JIT Access Error:', error);
        return {
            success: false,
            error: error.message,
            user: user?.email || 'unknown',
            timestamp: new Date().toISOString()
        };
    }
};

/**
 * Handle access request validation and workflow initiation
 */
async function handleAccessRequest(user, justification, duration, maxDurationHours, approvalRequired) {
    // Validate request parameters
    const validation = validateAccessRequest(user, justification, duration, maxDurationHours);
    if (!validation.valid) {
        throw new Error(validation.error);
    }
    
    // Perform risk assessment
    const riskAssessment = await performRiskAssessment(user);
    
    // Generate unique request ID
    const requestId = generateRequestId();
    
    // Calculate expiration time
    const expirationTime = new Date(Date.now() + duration * 60 * 60 * 1000);
    
    // Create access request record
    const accessRequest = {
        id: requestId,
        user: {
            email: user.email,
            employee_id: user.employee_id,
            department: user.department
        },
        justification: justification,
        duration: duration,
        status: approvalRequired ? 'pending_approval' : 'auto_approved',
        risk_score: riskAssessment.score,
        risk_factors: riskAssessment.factors,
        request_time: new Date().toISOString(),
        expiration_time: expirationTime.toISOString(),
        approval_required: approvalRequired
    };
    
    // Store request in database (simulated)
    await storeAccessRequest(accessRequest);
    
    // Send notifications
    if (approvalRequired) {
        await sendApprovalNotification(accessRequest);
    } else {
        // Auto-approve low-risk requests
        await scheduleAccessGranting(accessRequest);
    }
    
    // Log security event
    await logSecurityEvent('jit_access_requested', accessRequest);
    
    return {
        success: true,
        action: 'request',
        request_id: requestId,
        status: accessRequest.status,
        risk_score: riskAssessment.score,
        expiration_time: expirationTime.toISOString(),
        approval_required: approvalRequired,
        estimated_approval_time: approvalRequired ? '15 minutes' : 'immediate'
    };
}

/**
 * Handle access approval and privilege elevation
 */
async function handleAccessApproval(iamAccessGroups, user, approver) {
    // Validate approver permissions
    const approverValidation = await validateApprover(approver, user);
    if (!approverValidation.valid) {
        throw new Error(approverValidation.error);
    }
    
    // Add user to privileged access group
    const privilegedGroupId = process.env.PRIVILEGED_ACCESS_GROUP_ID;
    
    const addMemberParams = {
        accessGroupId: privilegedGroupId,
        members: [{
            iam_id: user.iam_id,
            type: 'user'
        }]
    };
    
    const membershipResult = await iamAccessGroups.addMembersToAccessGroup(addMemberParams);
    
    // Schedule automatic revocation
    const revocationTime = new Date(Date.now() + 4 * 60 * 60 * 1000); // 4 hours
    await scheduleAccessRevocation(user, revocationTime);
    
    // Update request status
    await updateRequestStatus(user.request_id, 'approved', approver);
    
    // Send confirmation notifications
    await sendAccessGrantedNotification(user, approver, revocationTime);
    
    // Log security event
    await logSecurityEvent('jit_access_approved', {
        user: user,
        approver: approver,
        granted_at: new Date().toISOString(),
        expires_at: revocationTime.toISOString()
    });
    
    return {
        success: true,
        action: 'approve',
        user: user.email,
        approver: approver.email,
        access_granted: new Date().toISOString(),
        auto_revocation_scheduled: revocationTime.toISOString(),
        privileged_group_id: privilegedGroupId
    };
}

/**
 * Handle access revocation and privilege removal
 */
async function handleAccessRevocation(iamAccessGroups, user) {
    // Remove user from privileged access group
    const privilegedGroupId = process.env.PRIVILEGED_ACCESS_GROUP_ID;
    
    const removeMemberParams = {
        accessGroupId: privilegedGroupId,
        iamId: user.iam_id
    };
    
    await iamAccessGroups.removeMemberFromAccessGroup(removeMemberParams);
    
    // Update request status
    await updateRequestStatus(user.request_id, 'revoked');
    
    // Send revocation notification
    await sendAccessRevokedNotification(user);
    
    // Log security event
    await logSecurityEvent('jit_access_revoked', {
        user: user,
        revoked_at: new Date().toISOString(),
        reason: 'automatic_expiration'
    });
    
    return {
        success: true,
        action: 'revoke',
        user: user.email,
        access_revoked: new Date().toISOString(),
        privileged_group_id: privilegedGroupId
    };
}

/**
 * Validate access request parameters
 */
function validateAccessRequest(user, justification, duration, maxDurationHours) {
    if (!user || !user.email) {
        return { valid: false, error: 'User email is required' };
    }
    
    if (!justification || justification.length < 20) {
        return { valid: false, error: 'Justification must be at least 20 characters' };
    }
    
    if (!duration || duration <= 0) {
        return { valid: false, error: 'Duration must be greater than 0' };
    }
    
    if (duration > maxDurationHours) {
        return { valid: false, error: `Maximum access duration is $${maxDurationHours} hours` };
    }
    
    return { valid: true };
}

/**
 * Perform risk assessment for access request
 */
async function performRiskAssessment(user) {
    let riskScore = 0;
    const riskFactors = [];
    
    // Time-based risk assessment
    const currentHour = new Date().getHours();
    if (currentHour < 8 || currentHour > 18) {
        riskScore += 15;
        riskFactors.push('Request outside business hours');
    }
    
    // Department-based risk assessment
    const highRiskDepartments = ['Finance', 'Security'];
    if (highRiskDepartments.includes(user.department)) {
        riskScore += 10;
        riskFactors.push('High-risk department');
    }
    
    // Recent access pattern analysis
    const recentAccess = await getRecentAccessHistory(user.email);
    if (recentAccess.privileged_access_count > 3) {
        riskScore += 20;
        riskFactors.push('Frequent privileged access requests');
    }
    
    // Location-based risk (simulated)
    if (user.location && user.location.country !== 'US') {
        riskScore += 25;
        riskFactors.push('Access from non-US location');
    }
    
    return {
        score: Math.min(riskScore, 100),
        level: getRiskLevel(riskScore),
        factors: riskFactors
    };
}

/**
 * Validate approver permissions
 */
async function validateApprover(approver, user) {
    if (!approver || !approver.email) {
        return { valid: false, error: 'Approver email is required' };
    }
    
    // Check if approver is user's manager
    if (user.manager_email && approver.email !== user.manager_email) {
        // Check if approver has delegation authority
        const hasDelegation = await checkDelegationAuthority(approver.email, user.department);
        if (!hasDelegation) {
            return { valid: false, error: 'Approver does not have authority for this user' };
        }
    }
    
    return { valid: true };
}

/**
 * Helper functions (simulated implementations)
 */
function generateRequestId() {
    return 'JIT-' + Date.now() + '-' + Math.random().toString(36).substr(2, 9);
}

function getRiskLevel(score) {
    if (score < 25) return 'Low';
    if (score < 50) return 'Medium';
    if (score < 75) return 'High';
    return 'Critical';
}

async function storeAccessRequest(request) {
    // Simulate database storage
    console.log('Storing access request:', request.id);
    return true;
}

async function sendApprovalNotification(request) {
    // Simulate sending approval notification
    console.log(`Approval notification sent for request $${request.id}`);
    return true;
}

async function scheduleAccessGranting(request) {
    // Simulate scheduling access granting
    console.log(`Access granting scheduled for request $${request.id}`);
    return true;
}

async function scheduleAccessRevocation(user, revocationTime) {
    // Simulate scheduling access revocation
    console.log(`Access revocation scheduled for $${user.email} at $${revocationTime}`);
    return true;
}

async function logSecurityEvent(eventType, eventData) {
    // Simulate security event logging
    console.log(`Security event logged: $${eventType}`, eventData);
    return true;
}

async function getRecentAccessHistory(email) {
    // Simulate access history retrieval
    return {
        privileged_access_count: Math.floor(Math.random() * 5),
        last_access: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString()
    };
}

async function checkDelegationAuthority(approverEmail, department) {
    // Simulate delegation authority check
    const delegationMap = {
        'security-manager@company.com': ['Security', 'Operations'],
        'finance-director@company.com': ['Finance', 'Accounting'],
        'engineering-director@company.com': ['Engineering', 'DevOps']
    };
    
    return delegationMap[approverEmail]?.includes(department) || false;
}

async function updateRequestStatus(requestId, status, approver = null) {
    // Simulate request status update
    console.log(`Request $${requestId} status updated to $${status}`);
    return true;
}

async function sendAccessGrantedNotification(user, approver, expirationTime) {
    // Simulate access granted notification
    console.log(`Access granted notification sent to $${user.email}`);
    return true;
}

async function sendAccessRevokedNotification(user) {
    // Simulate access revoked notification
    console.log(`Access revoked notification sent to $${user.email}`);
    return true;
}
