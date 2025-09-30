/**
 * User Provisioning Automation Function
 * Topic 7.2: Identity and Access Management (IAM) Integration
 * 
 * This function handles automated user lifecycle management including provisioning,
 * deprovisioning, role changes, and access group assignments based on HR events.
 */

const { AppIDManagementV4 } = require('ibm-appid-management');
const { IamAccessGroupsV2 } = require('@ibm-cloud/platform-services');

/**
 * Main function handler for user provisioning automation
 * @param {Object} params - Function parameters
 * @param {string} params.action - Action to perform: 'provision', 'deprovision', 'update', 'transfer'
 * @param {Object} params.user - User information from HR system
 * @param {Object} params.hr_event - HR event details
 * @param {string} params.webhook_token - Webhook authentication token
 * @returns {Object} Provisioning result
 */
exports.main = async function(params) {
    const { action, user, hr_event, webhook_token } = params;
    
    // Configuration from template variables
    const appIdInstanceGuid = process.env.APPID_INSTANCE_GUID || '${appid_instance_guid}';
    const departmentMappings = JSON.parse(process.env.DEPARTMENT_MAPPINGS || '${jsonencode(department_mappings)}');
    
    try {
        // Validate webhook token
        if (!validateWebhookToken(webhook_token)) {
            throw new Error('Invalid webhook token');
        }
        
        // Initialize IBM Cloud SDK clients
        const appIdClient = new AppIDManagementV4({
            authenticator: new IamAuthenticator({
                apikey: process.env.IAM_API_KEY
            }),
            serviceUrl: `https://us-south.appid.cloud.ibm.com/management/v4/$${appIdInstanceGuid}`
        });
        
        const iamAccessGroups = IamAccessGroupsV2.newInstance({
            authenticator: new IamAuthenticator({
                apikey: process.env.IAM_API_KEY
            })
        });
        
        console.log(`Processing user provisioning action: $${action} for user: $${user?.email}`);
        
        switch (action) {
            case 'provision':
                return await provisionUser(appIdClient, iamAccessGroups, user, departmentMappings);
            case 'deprovision':
                return await deprovisionUser(appIdClient, iamAccessGroups, user);
            case 'update':
                return await updateUser(appIdClient, iamAccessGroups, user, hr_event, departmentMappings);
            case 'transfer':
                return await transferUser(appIdClient, iamAccessGroups, user, hr_event, departmentMappings);
            default:
                throw new Error(`Unknown action: $${action}`);
        }
        
    } catch (error) {
        console.error('User Provisioning Error:', error);
        
        // Send failure notification
        await sendProvisioningFailureNotification(user, action, error.message);
        
        return {
            success: false,
            action: action,
            user: user?.email || 'unknown',
            error: error.message,
            timestamp: new Date().toISOString()
        };
    }
};

/**
 * Provision new user account and access
 */
async function provisionUser(appIdClient, iamAccessGroups, user, departmentMappings) {
    console.log(`Provisioning new user: $${user.email}`);
    
    // Validate user data
    const validation = validateUserData(user);
    if (!validation.valid) {
        throw new Error(`Invalid user data: $${validation.error}`);
    }
    
    // Create user in App ID directory
    const appIdUser = await createAppIdUser(appIdClient, user);
    
    // Determine access groups based on department and role
    const accessGroups = determineAccessGroups(user, departmentMappings);
    
    // Add user to appropriate access groups
    const groupMemberships = await addUserToAccessGroups(iamAccessGroups, appIdUser.id, accessGroups);
    
    // Set up initial user profile and preferences
    await setupUserProfile(appIdClient, appIdUser.id, user);
    
    // Generate temporary password and send welcome email
    const temporaryPassword = generateTemporaryPassword();
    await setTemporaryPassword(appIdClient, appIdUser.id, temporaryPassword);
    await sendWelcomeEmail(user, temporaryPassword);
    
    // Create audit trail
    await createProvisioningAuditTrail(user, accessGroups, 'provision');
    
    // Schedule access review
    await scheduleAccessReview(user, 90); // 90 days
    
    console.log(`User provisioning completed for: $${user.email}`);
    
    return {
        success: true,
        action: 'provision',
        user: {
            email: user.email,
            app_id_user_id: appIdUser.id,
            employee_id: user.employee_id,
            department: user.department
        },
        access_groups: accessGroups,
        group_memberships: groupMemberships,
        temporary_password_sent: true,
        access_review_scheduled: true,
        timestamp: new Date().toISOString()
    };
}

/**
 * Deprovision user account and revoke all access
 */
async function deprovisionUser(appIdClient, iamAccessGroups, user) {
    console.log(`Deprovisioning user: $${user.email}`);
    
    // Find user in App ID directory
    const appIdUser = await findAppIdUser(appIdClient, user.email);
    if (!appIdUser) {
        console.log(`User not found in App ID: $${user.email}`);
        return {
            success: true,
            action: 'deprovision',
            user: user.email,
            message: 'User not found in directory',
            timestamp: new Date().toISOString()
        };
    }
    
    // Get user's current access groups
    const currentAccessGroups = await getUserAccessGroups(iamAccessGroups, appIdUser.id);
    
    // Remove user from all access groups
    const removalResults = await removeUserFromAllAccessGroups(iamAccessGroups, appIdUser.id, currentAccessGroups);
    
    // Disable user account (don't delete for audit purposes)
    await disableAppIdUser(appIdClient, appIdUser.id);
    
    // Revoke all active sessions
    await revokeUserSessions(appIdClient, appIdUser.id);
    
    // Archive user data for compliance
    await archiveUserData(user, currentAccessGroups);
    
    // Create audit trail
    await createProvisioningAuditTrail(user, currentAccessGroups, 'deprovision');
    
    // Send deprovisioning confirmation
    await sendDeprovisioningNotification(user, currentAccessGroups);
    
    console.log(`User deprovisioning completed for: $${user.email}`);
    
    return {
        success: true,
        action: 'deprovision',
        user: {
            email: user.email,
            app_id_user_id: appIdUser.id,
            employee_id: user.employee_id
        },
        access_groups_removed: currentAccessGroups,
        removal_results: removalResults,
        account_disabled: true,
        sessions_revoked: true,
        data_archived: true,
        timestamp: new Date().toISOString()
    };
}

/**
 * Update user information and access based on HR changes
 */
async function updateUser(appIdClient, iamAccessGroups, user, hrEvent, departmentMappings) {
    console.log(`Updating user: $${user.email}, Event: $${hrEvent.type}`);
    
    // Find user in App ID directory
    const appIdUser = await findAppIdUser(appIdClient, user.email);
    if (!appIdUser) {
        throw new Error(`User not found in App ID: $${user.email}`);
    }
    
    const updateResults = {
        profile_updated: false,
        access_groups_changed: false,
        role_changed: false
    };
    
    // Update user profile information
    if (hrEvent.type === 'profile_update') {
        await updateAppIdUserProfile(appIdClient, appIdUser.id, user);
        updateResults.profile_updated = true;
    }
    
    // Handle role changes
    if (hrEvent.type === 'role_change') {
        const newAccessGroups = determineAccessGroups(user, departmentMappings);
        const currentAccessGroups = await getUserAccessGroups(iamAccessGroups, appIdUser.id);
        
        // Calculate access group changes
        const groupsToAdd = newAccessGroups.filter(group => !currentAccessGroups.includes(group));
        const groupsToRemove = currentAccessGroups.filter(group => !newAccessGroups.includes(group));
        
        // Apply access group changes
        if (groupsToAdd.length > 0) {
            await addUserToAccessGroups(iamAccessGroups, appIdUser.id, groupsToAdd);
        }
        if (groupsToRemove.length > 0) {
            await removeUserFromAccessGroups(iamAccessGroups, appIdUser.id, groupsToRemove);
        }
        
        updateResults.access_groups_changed = groupsToAdd.length > 0 || groupsToRemove.length > 0;
        updateResults.role_changed = true;
        updateResults.groups_added = groupsToAdd;
        updateResults.groups_removed = groupsToRemove;
    }
    
    // Handle manager changes
    if (hrEvent.type === 'manager_change') {
        await updateUserManager(appIdClient, appIdUser.id, user.manager_email);
        updateResults.manager_updated = true;
    }
    
    // Create audit trail
    await createProvisioningAuditTrail(user, [], 'update', hrEvent);
    
    // Send update notification
    await sendUpdateNotification(user, updateResults, hrEvent);
    
    console.log(`User update completed for: $${user.email}`);
    
    return {
        success: true,
        action: 'update',
        user: {
            email: user.email,
            app_id_user_id: appIdUser.id,
            employee_id: user.employee_id
        },
        hr_event: hrEvent,
        update_results: updateResults,
        timestamp: new Date().toISOString()
    };
}

/**
 * Transfer user between departments
 */
async function transferUser(appIdClient, iamAccessGroups, user, hrEvent, departmentMappings) {
    console.log(`Transferring user: $${user.email} from $${hrEvent.old_department} to $${user.department}`);
    
    // Find user in App ID directory
    const appIdUser = await findAppIdUser(appIdClient, user.email);
    if (!appIdUser) {
        throw new Error(`User not found in App ID: $${user.email}`);
    }
    
    // Get current access groups
    const currentAccessGroups = await getUserAccessGroups(iamAccessGroups, appIdUser.id);
    
    // Determine new access groups for new department
    const newAccessGroups = determineAccessGroups(user, departmentMappings);
    
    // Calculate access changes
    const groupsToAdd = newAccessGroups.filter(group => !currentAccessGroups.includes(group));
    const groupsToRemove = currentAccessGroups.filter(group => !newAccessGroups.includes(group));
    
    // Apply access group changes with approval workflow for sensitive transfers
    const requiresApproval = checkTransferApprovalRequired(hrEvent.old_department, user.department);
    
    if (requiresApproval) {
        await requestTransferApproval(user, hrEvent, groupsToAdd, groupsToRemove);
        
        return {
            success: true,
            action: 'transfer',
            user: user.email,
            status: 'pending_approval',
            old_department: hrEvent.old_department,
            new_department: user.department,
            pending_changes: {
                groups_to_add: groupsToAdd,
                groups_to_remove: groupsToRemove
            },
            timestamp: new Date().toISOString()
        };
    }
    
    // Execute transfer immediately for non-sensitive transfers
    if (groupsToRemove.length > 0) {
        await removeUserFromAccessGroups(iamAccessGroups, appIdUser.id, groupsToRemove);
    }
    if (groupsToAdd.length > 0) {
        await addUserToAccessGroups(iamAccessGroups, appIdUser.id, groupsToAdd);
    }
    
    // Update user profile with new department information
    await updateAppIdUserProfile(appIdClient, appIdUser.id, user);
    
    // Create audit trail
    await createProvisioningAuditTrail(user, newAccessGroups, 'transfer', hrEvent);
    
    // Send transfer notification
    await sendTransferNotification(user, hrEvent, groupsToAdd, groupsToRemove);
    
    console.log(`User transfer completed for: $${user.email}`);
    
    return {
        success: true,
        action: 'transfer',
        user: {
            email: user.email,
            app_id_user_id: appIdUser.id,
            employee_id: user.employee_id
        },
        old_department: hrEvent.old_department,
        new_department: user.department,
        access_changes: {
            groups_added: groupsToAdd,
            groups_removed: groupsToRemove
        },
        approval_required: false,
        timestamp: new Date().toISOString()
    };
}

/**
 * Helper functions
 */
function validateWebhookToken(token) {
    const expectedToken = process.env.HR_WEBHOOK_TOKEN || 'demo-token';
    return token === expectedToken;
}

function validateUserData(user) {
    if (!user.email || !user.first_name || !user.last_name) {
        return { valid: false, error: 'Missing required user fields' };
    }
    if (!user.employee_id || !user.department) {
        return { valid: false, error: 'Missing employee ID or department' };
    }
    return { valid: true };
}

function determineAccessGroups(user, departmentMappings) {
    const department = user.department;
    const accessLevel = user.access_level || 'standard';
    
    if (!departmentMappings[department]) {
        console.warn(`No access mapping found for department: $${department}`);
        return ['default-users'];
    }
    
    const mapping = departmentMappings[department];
    let accessGroups = [...mapping.access_groups];
    
    // Add elevated permissions for elevated access level
    if (accessLevel === 'elevated' && mapping.elevated_permissions) {
        accessGroups.push(...mapping.elevated_permissions.map(perm => `$${department.toLowerCase()}-$${perm}`));
    }
    
    return accessGroups;
}

function generateTemporaryPassword() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*';
    let password = '';
    for (let i = 0; i < 12; i++) {
        password += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return password;
}

function checkTransferApprovalRequired(oldDept, newDept) {
    const sensitiveTransfers = [
        { from: 'Finance', to: 'Engineering' },
        { from: 'Security', to: 'Operations' },
        { from: 'Engineering', to: 'Finance' }
    ];
    
    return sensitiveTransfers.some(transfer => 
        transfer.from === oldDept && transfer.to === newDept
    );
}

// Simulated API functions (would be actual IBM Cloud SDK calls in production)
async function createAppIdUser(client, user) {
    console.log(`Creating App ID user: $${user.email}`);
    return { id: `appid-user-$${Date.now()}`, email: user.email };
}

async function findAppIdUser(client, email) {
    console.log(`Finding App ID user: $${email}`);
    return { id: `appid-user-existing`, email: email };
}

async function addUserToAccessGroups(client, userId, groups) {
    console.log(`Adding user $${userId} to groups: $${groups.join(', ')}`);
    return groups.map(group => ({ group, status: 'added' }));
}

async function removeUserFromAccessGroups(client, userId, groups) {
    console.log(`Removing user $${userId} from groups: $${groups.join(', ')}`);
    return groups.map(group => ({ group, status: 'removed' }));
}

async function removeUserFromAllAccessGroups(client, userId, groups) {
    return await removeUserFromAccessGroups(client, userId, groups);
}

async function getUserAccessGroups(client, userId) {
    console.log(`Getting access groups for user: $${userId}`);
    return ['default-users', 'department-access'];
}

async function disableAppIdUser(client, userId) {
    console.log(`Disabling App ID user: $${userId}`);
    return true;
}

async function revokeUserSessions(client, userId) {
    console.log(`Revoking sessions for user: $${userId}`);
    return true;
}

async function setupUserProfile(client, userId, user) {
    console.log(`Setting up profile for user: $${userId}`);
    return true;
}

async function setTemporaryPassword(client, userId, password) {
    console.log(`Setting temporary password for user: $${userId}`);
    return true;
}

async function updateAppIdUserProfile(client, userId, user) {
    console.log(`Updating profile for user: $${userId}`);
    return true;
}

async function updateUserManager(client, userId, managerEmail) {
    console.log(`Updating manager for user: $${userId} to $${managerEmail}`);
    return true;
}

// Notification functions
async function sendWelcomeEmail(user, password) {
    console.log(`Sending welcome email to: $${user.email}`);
    return true;
}

async function sendDeprovisioningNotification(user, groups) {
    console.log(`Sending deprovisioning notification for: $${user.email}`);
    return true;
}

async function sendUpdateNotification(user, results, event) {
    console.log(`Sending update notification for: $${user.email}`);
    return true;
}

async function sendTransferNotification(user, event, added, removed) {
    console.log(`Sending transfer notification for: $${user.email}`);
    return true;
}

async function sendProvisioningFailureNotification(user, action, error) {
    console.log(`Sending failure notification for: $${user?.email}, Action: $${action}, Error: $${error}`);
    return true;
}

async function requestTransferApproval(user, event, toAdd, toRemove) {
    console.log(`Requesting transfer approval for: $${user.email}`);
    return true;
}

// Audit and compliance functions
async function createProvisioningAuditTrail(user, groups, action, event = null) {
    console.log(`Creating audit trail for: $${user.email}, Action: $${action}`);
    return true;
}

async function archiveUserData(user, groups) {
    console.log(`Archiving data for: $${user.email}`);
    return true;
}

async function scheduleAccessReview(user, days) {
    console.log(`Scheduling access review for: $${user.email} in $${days} days`);
    return true;
}
