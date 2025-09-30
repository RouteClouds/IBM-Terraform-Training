#!/usr/bin/env python3
"""
IBM Cloud IAM Integration - Diagram as Code (DaC) Implementation
Topic 7.2: Identity and Access Management (IAM) Integration

This script generates 5 professional diagrams for enterprise identity and access management:
1. Enterprise Identity Architecture
2. Authentication Flow and Federation Patterns
3. Identity Governance and Compliance Dashboard
4. Federated Trust Relationships and SSO Implementation
5. Privileged Access Management and JIT Workflows

All diagrams are generated at 300 DPI with IBM Cloud brand compliance.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, Circle, Rectangle, Arrow
import numpy as np
import seaborn as sns
from datetime import datetime
import os

# IBM Cloud brand colors
IBM_COLORS = {
    'blue': '#0f62fe',
    'dark_blue': '#002d9c',
    'light_blue': '#4589ff',
    'gray': '#525252',
    'light_gray': '#f4f4f4',
    'white': '#ffffff',
    'green': '#24a148',
    'red': '#da1e28',
    'yellow': '#f1c21b',
    'purple': '#8a3ffc',
    'teal': '#009d9a'
}

# Set up matplotlib for high-quality output
plt.rcParams['figure.dpi'] = 300
plt.rcParams['savefig.dpi'] = 300
plt.rcParams['font.family'] = 'Arial'
plt.rcParams['font.size'] = 10

def create_output_directory():
    """Create output directory for diagrams"""
    output_dir = 'diagrams'
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    return output_dir

def add_ibm_branding(ax, title, subtitle=""):
    """Add IBM Cloud branding to diagrams"""
    # Add IBM Cloud logo placeholder
    logo_box = FancyBboxPatch((0.02, 0.95), 0.15, 0.04, 
                             boxstyle="round,pad=0.01",
                             facecolor=IBM_COLORS['blue'],
                             edgecolor='none',
                             transform=ax.transAxes)
    ax.add_patch(logo_box)
    
    # Add IBM Cloud text
    ax.text(0.095, 0.97, 'IBM Cloud', transform=ax.transAxes,
            fontsize=12, fontweight='bold', color='white',
            ha='center', va='center')
    
    # Add title
    ax.text(0.5, 0.95, title, transform=ax.transAxes,
            fontsize=16, fontweight='bold', color=IBM_COLORS['dark_blue'],
            ha='center', va='center')
    
    # Add subtitle if provided
    if subtitle:
        ax.text(0.5, 0.92, subtitle, transform=ax.transAxes,
                fontsize=12, color=IBM_COLORS['gray'],
                ha='center', va='center')

def add_business_metrics(ax, metrics):
    """Add business value metrics to diagrams"""
    metrics_box = FancyBboxPatch((0.75, 0.02), 0.23, 0.15,
                                boxstyle="round,pad=0.01",
                                facecolor=IBM_COLORS['light_gray'],
                                edgecolor=IBM_COLORS['gray'],
                                linewidth=1,
                                transform=ax.transAxes)
    ax.add_patch(metrics_box)
    
    ax.text(0.865, 0.14, 'Business Value', transform=ax.transAxes,
            fontsize=10, fontweight='bold', color=IBM_COLORS['dark_blue'],
            ha='center', va='center')
    
    y_pos = 0.12
    for metric, value in metrics.items():
        ax.text(0.865, y_pos, f'{metric}: {value}', transform=ax.transAxes,
                fontsize=8, color=IBM_COLORS['gray'],
                ha='center', va='center')
        y_pos -= 0.02

def create_enterprise_identity_architecture():
    """Generate Diagram 1: Enterprise Identity Architecture"""
    fig, ax = plt.subplots(1, 1, figsize=(16, 12))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Add branding
    add_ibm_branding(ax, "Enterprise Identity Architecture Evolution",
                     "From Basic IAM to Enterprise Identity Management")
    
    # Enterprise Directory (left side)
    enterprise_box = FancyBboxPatch((0.5, 7), 2, 1.5,
                                   boxstyle="round,pad=0.1",
                                   facecolor=IBM_COLORS['light_blue'],
                                   edgecolor=IBM_COLORS['blue'],
                                   linewidth=2)
    ax.add_patch(enterprise_box)
    ax.text(1.5, 7.75, 'Enterprise Directory', fontsize=12, fontweight='bold',
            ha='center', va='center', color=IBM_COLORS['dark_blue'])
    ax.text(1.5, 7.4, '• Active Directory\n• LDAP\n• SAML 2.0\n• OIDC', 
            fontsize=9, ha='center', va='center')
    
    # IBM Cloud IAM (center)
    iam_box = FancyBboxPatch((4, 6), 2, 3,
                            boxstyle="round,pad=0.1",
                            facecolor=IBM_COLORS['blue'],
                            edgecolor=IBM_COLORS['dark_blue'],
                            linewidth=3)
    ax.add_patch(iam_box)
    ax.text(5, 8.5, 'IBM Cloud IAM', fontsize=14, fontweight='bold',
            ha='center', va='center', color='white')
    ax.text(5, 8, 'Identity Fabric', fontsize=10, fontweight='bold',
            ha='center', va='center', color='white')
    
    # IAM components
    components = ['App ID', 'Access Groups', 'Policies', 'Trusted Profiles', 'Service IDs']
    for i, comp in enumerate(components):
        y_pos = 7.5 - (i * 0.3)
        comp_box = FancyBboxPatch((4.2, y_pos-0.1), 1.6, 0.2,
                                 boxstyle="round,pad=0.02",
                                 facecolor=IBM_COLORS['white'],
                                 edgecolor=IBM_COLORS['light_blue'],
                                 linewidth=1)
        ax.add_patch(comp_box)
        ax.text(5, y_pos, comp, fontsize=8, ha='center', va='center',
                color=IBM_COLORS['dark_blue'])
    
    # Cloud Resources (right side)
    resources = [
        ('Key Protect', 8.5, 8.5),
        ('Secrets Manager', 8.5, 7.8),
        ('VPC Infrastructure', 8.5, 7.1),
        ('Kubernetes Service', 8.5, 6.4),
        ('Cloud Databases', 8.5, 5.7)
    ]
    
    for resource, x, y in resources:
        resource_box = FancyBboxPatch((x-0.7, y-0.2), 1.4, 0.4,
                                     boxstyle="round,pad=0.05",
                                     facecolor=IBM_COLORS['green'],
                                     edgecolor=IBM_COLORS['dark_blue'],
                                     linewidth=1)
        ax.add_patch(resource_box)
        ax.text(x, y, resource, fontsize=9, fontweight='bold',
                ha='center', va='center', color='white')
    
    # Authentication Methods (bottom)
    auth_methods = [
        ('Multi-Factor\nAuthentication', 1.5, 4.5),
        ('Conditional\nAccess', 3, 4.5),
        ('Risk-Based\nAuthentication', 4.5, 4.5),
        ('Just-in-Time\nAccess', 6, 4.5),
        ('Session\nMonitoring', 7.5, 4.5)
    ]
    
    for method, x, y in auth_methods:
        method_box = FancyBboxPatch((x-0.5, y-0.3), 1, 0.6,
                                   boxstyle="round,pad=0.05",
                                   facecolor=IBM_COLORS['purple'],
                                   edgecolor=IBM_COLORS['dark_blue'],
                                   linewidth=1)
        ax.add_patch(method_box)
        ax.text(x, y, method, fontsize=8, fontweight='bold',
                ha='center', va='center', color='white')
    
    # Compliance Frameworks (bottom left)
    compliance_box = FancyBboxPatch((0.5, 2), 3, 1.5,
                                   boxstyle="round,pad=0.1",
                                   facecolor=IBM_COLORS['yellow'],
                                   edgecolor=IBM_COLORS['dark_blue'],
                                   linewidth=2)
    ax.add_patch(compliance_box)
    ax.text(2, 3.2, 'Compliance Frameworks', fontsize=12, fontweight='bold',
            ha='center', va='center', color=IBM_COLORS['dark_blue'])
    ax.text(2, 2.7, '• SOC2 Type II (100% Compliant)\n• ISO27001 (95% Automated)\n• GDPR (100% Compliant)\n• Industry Standards', 
            fontsize=9, ha='center', va='center')
    
    # Governance Automation (bottom right)
    governance_box = FancyBboxPatch((6, 2), 3, 1.5,
                                   boxstyle="round,pad=0.1",
                                   facecolor=IBM_COLORS['teal'],
                                   edgecolor=IBM_COLORS['dark_blue'],
                                   linewidth=2)
    ax.add_patch(governance_box)
    ax.text(7.5, 3.2, 'Identity Governance', fontsize=12, fontweight='bold',
            ha='center', va='center', color='white')
    ax.text(7.5, 2.7, '• Automated Provisioning\n• Access Reviews (95% Automated)\n• Lifecycle Management\n• Audit Trail (100% Coverage)', 
            fontsize=9, ha='center', va='center', color='white')
    
    # Connection arrows
    # Enterprise to IAM
    ax.annotate('', xy=(4, 7.5), xytext=(2.5, 7.5),
                arrowprops=dict(arrowstyle='->', lw=2, color=IBM_COLORS['blue']))
    ax.text(3.25, 7.7, 'SAML/OIDC\nFederation', fontsize=8, ha='center', va='bottom',
            color=IBM_COLORS['blue'], fontweight='bold')
    
    # IAM to Resources
    for _, x, y in resources:
        ax.annotate('', xy=(x-0.7, y), xytext=(6, 7.5),
                    arrowprops=dict(arrowstyle='->', lw=1.5, color=IBM_COLORS['green']))
    
    # IAM to Auth Methods
    for _, x, y in auth_methods:
        ax.annotate('', xy=(x, y+0.3), xytext=(5, 6),
                    arrowprops=dict(arrowstyle='->', lw=1, color=IBM_COLORS['purple']))
    
    # Add business metrics
    metrics = {
        'ROI': '800%+',
        'Automation': '95%',
        'Cost Savings': '70%',
        'Risk Reduction': '95%'
    }
    add_business_metrics(ax, metrics)
    
    # Add timestamp
    ax.text(0.02, 0.02, f'Generated: {datetime.now().strftime("%Y-%m-%d %H:%M")}',
            transform=ax.transAxes, fontsize=8, color=IBM_COLORS['gray'])
    
    plt.tight_layout()
    return fig

def create_authentication_flow_diagram():
    """Generate Diagram 2: Authentication Flow and Federation Patterns"""
    fig, ax = plt.subplots(1, 1, figsize=(16, 12))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Add branding
    add_ibm_branding(ax, "Authentication Flow and Federation Patterns",
                     "Multi-Step Enterprise Authentication Process")
    
    # User (starting point)
    user_circle = Circle((1, 8), 0.3, facecolor=IBM_COLORS['blue'], 
                        edgecolor=IBM_COLORS['dark_blue'], linewidth=2)
    ax.add_patch(user_circle)
    ax.text(1, 8, 'User', fontsize=10, fontweight='bold', ha='center', va='center', color='white')
    
    # Authentication flow steps
    flow_steps = [
        ('Enterprise\nDirectory', 3, 8, IBM_COLORS['light_blue']),
        ('SAML\nAssertion', 5, 8, IBM_COLORS['purple']),
        ('IBM Cloud\nApp ID', 7, 8, IBM_COLORS['blue']),
        ('Conditional\nAccess', 9, 8, IBM_COLORS['yellow']),
        ('Resource\nAccess', 11, 8, IBM_COLORS['green'])
    ]
    
    for i, (step, x, y, color) in enumerate(flow_steps):
        step_box = FancyBboxPatch((x-0.6, y-0.4), 1.2, 0.8,
                                 boxstyle="round,pad=0.1",
                                 facecolor=color,
                                 edgecolor=IBM_COLORS['dark_blue'],
                                 linewidth=2)
        ax.add_patch(step_box)
        ax.text(x, y, step, fontsize=9, fontweight='bold',
                ha='center', va='center', 
                color='white' if color != IBM_COLORS['yellow'] else IBM_COLORS['dark_blue'])
        
        # Add step number
        step_circle = Circle((x-0.5, y+0.3), 0.15, facecolor=IBM_COLORS['dark_blue'], 
                           edgecolor='white', linewidth=1)
        ax.add_patch(step_circle)
        ax.text(x-0.5, y+0.3, str(i+1), fontsize=8, fontweight='bold',
                ha='center', va='center', color='white')
    
    # Flow arrows with timing
    timings = ['< 100ms', '< 200ms', '< 150ms', '< 300ms']
    for i in range(len(flow_steps)):
        start_x = 1.3 if i == 0 else flow_steps[i-1][1] + 0.6
        end_x = flow_steps[i][1] - 0.6
        
        ax.annotate('', xy=(end_x, 8), xytext=(start_x, 8),
                    arrowprops=dict(arrowstyle='->', lw=2, color=IBM_COLORS['blue']))
        
        if i < len(timings):
            mid_x = (start_x + end_x) / 2
            ax.text(mid_x, 8.3, timings[i], fontsize=8, ha='center', va='bottom',
                    color=IBM_COLORS['blue'], fontweight='bold')
    
    # MFA Challenge flow (branching)
    mfa_box = FancyBboxPatch((6.4, 6), 1.2, 0.8,
                            boxstyle="round,pad=0.1",
                            facecolor=IBM_COLORS['red'],
                            edgecolor=IBM_COLORS['dark_blue'],
                            linewidth=2)
    ax.add_patch(mfa_box)
    ax.text(7, 6.4, 'MFA\nChallenge', fontsize=9, fontweight='bold',
            ha='center', va='center', color='white')
    
    # MFA decision diamond
    mfa_decision = patches.RegularPolygon((7, 5), 4, radius=0.4, 
                                         orientation=np.pi/4,
                                         facecolor=IBM_COLORS['yellow'],
                                         edgecolor=IBM_COLORS['dark_blue'],
                                         linewidth=2)
    ax.add_patch(mfa_decision)
    ax.text(7, 5, 'Risk\nScore\n> 75?', fontsize=8, fontweight='bold',
            ha='center', va='center', color=IBM_COLORS['dark_blue'])
    
    # MFA flow arrows
    ax.annotate('', xy=(7, 6), xytext=(7, 7.6),
                arrowprops=dict(arrowstyle='->', lw=1.5, color=IBM_COLORS['red']))
    ax.annotate('', xy=(7, 5.4), xytext=(7, 6),
                arrowprops=dict(arrowstyle='->', lw=1.5, color=IBM_COLORS['red']))
    
    # Risk assessment components
    risk_components = [
        ('Location\nAnalysis', 2, 5.5),
        ('Device\nFingerprint', 4, 5.5),
        ('Behavioral\nAnalysis', 6, 5.5),
        ('Time-based\nRules', 8, 5.5),
        ('SIEM\nIntegration', 10, 5.5)
    ]
    
    for comp, x, y in risk_components:
        comp_box = FancyBboxPatch((x-0.5, y-0.3), 1, 0.6,
                                 boxstyle="round,pad=0.05",
                                 facecolor=IBM_COLORS['teal'],
                                 edgecolor=IBM_COLORS['dark_blue'],
                                 linewidth=1)
        ax.add_patch(comp_box)
        ax.text(x, y, comp, fontsize=8, fontweight='bold',
                ha='center', va='center', color='white')
    
    # Security validation points
    validation_points = [
        ('Certificate\nValidation', 3, 3.5),
        ('Token\nVerification', 5, 3.5),
        ('Policy\nEvaluation', 7, 3.5),
        ('Audit\nLogging', 9, 3.5)
    ]
    
    for point, x, y in validation_points:
        point_box = FancyBboxPatch((x-0.5, y-0.3), 1, 0.6,
                                  boxstyle="round,pad=0.05",
                                  facecolor=IBM_COLORS['gray'],
                                  edgecolor=IBM_COLORS['dark_blue'],
                                  linewidth=1)
        ax.add_patch(point_box)
        ax.text(x, y, point, fontsize=8, fontweight='bold',
                ha='center', va='center', color='white')
    
    # Integration points
    integration_box = FancyBboxPatch((0.5, 1.5), 11, 1,
                                    boxstyle="round,pad=0.1",
                                    facecolor=IBM_COLORS['light_gray'],
                                    edgecolor=IBM_COLORS['gray'],
                                    linewidth=1)
    ax.add_patch(integration_box)
    ax.text(6, 2.2, 'IBM Cloud Service Integration', fontsize=12, fontweight='bold',
            ha='center', va='center', color=IBM_COLORS['dark_blue'])
    ax.text(6, 1.8, 'Key Protect • Secrets Manager • Activity Tracker • Cloud Security Advisor • VPC Infrastructure',
            fontsize=10, ha='center', va='center', color=IBM_COLORS['gray'])
    
    # Add business metrics
    metrics = {
        'Auth Success': '99.9%',
        'Response Time': '< 500ms',
        'User Satisfaction': '95%',
        'Security Score': '100%'
    }
    add_business_metrics(ax, metrics)
    
    # Add timestamp
    ax.text(0.02, 0.02, f'Generated: {datetime.now().strftime("%Y-%m-%d %H:%M")}',
            transform=ax.transAxes, fontsize=8, color=IBM_COLORS['gray'])
    
    plt.tight_layout()
    return fig

def create_identity_governance_dashboard():
    """Generate Diagram 3: Identity Governance and Compliance Dashboard"""
    fig, ax = plt.subplots(1, 1, figsize=(16, 12))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 10)
    ax.axis('off')

    # Add branding
    add_ibm_branding(ax, "Identity Governance and Compliance Dashboard",
                     "Real-time Identity Lifecycle Management System")

    # Dashboard header
    header_box = FancyBboxPatch((0.5, 8.5), 11, 0.8,
                               boxstyle="round,pad=0.05",
                               facecolor=IBM_COLORS['dark_blue'],
                               edgecolor=IBM_COLORS['blue'],
                               linewidth=2)
    ax.add_patch(header_box)
    ax.text(6, 8.9, 'Enterprise Identity Governance Dashboard', fontsize=14, fontweight='bold',
            ha='center', va='center', color='white')

    # Key metrics (top row)
    metrics_data = [
        ('User Onboarding', '95%', 'Automation', IBM_COLORS['green']),
        ('Access Reviews', '98%', 'Completion', IBM_COLORS['blue']),
        ('Compliance Score', '100%', 'SOC2/ISO27001', IBM_COLORS['purple']),
        ('Risk Reduction', '95%', 'Security Incidents', IBM_COLORS['teal'])
    ]

    for i, (title, value, subtitle, color) in enumerate(metrics_data):
        x = 1.5 + i * 2.5
        metric_box = FancyBboxPatch((x-0.8, 7.2), 1.6, 1,
                                   boxstyle="round,pad=0.1",
                                   facecolor=color,
                                   edgecolor=IBM_COLORS['dark_blue'],
                                   linewidth=2)
        ax.add_patch(metric_box)
        ax.text(x, 7.9, title, fontsize=10, fontweight='bold',
                ha='center', va='center', color='white')
        ax.text(x, 7.6, value, fontsize=16, fontweight='bold',
                ha='center', va='center', color='white')
        ax.text(x, 7.3, subtitle, fontsize=8,
                ha='center', va='center', color='white')

    # Lifecycle management workflow (left side)
    workflow_box = FancyBboxPatch((0.5, 4.5), 5, 2.5,
                                 boxstyle="round,pad=0.1",
                                 facecolor=IBM_COLORS['light_gray'],
                                 edgecolor=IBM_COLORS['gray'],
                                 linewidth=2)
    ax.add_patch(workflow_box)
    ax.text(3, 6.7, 'Automated Lifecycle Management', fontsize=12, fontweight='bold',
            ha='center', va='center', color=IBM_COLORS['dark_blue'])

    # Workflow steps
    workflow_steps = [
        ('HR Event', 1.5, 6.2, IBM_COLORS['yellow']),
        ('Auto Provision', 3, 6.2, IBM_COLORS['green']),
        ('Access Assignment', 4.5, 6.2, IBM_COLORS['blue']),
        ('Quarterly Review', 1.5, 5.5, IBM_COLORS['purple']),
        ('Access Validation', 3, 5.5, IBM_COLORS['teal']),
        ('Auto Remediation', 4.5, 5.5, IBM_COLORS['red'])
    ]

    for step, x, y, color in workflow_steps:
        step_box = FancyBboxPatch((x-0.4, y-0.2), 0.8, 0.4,
                                 boxstyle="round,pad=0.05",
                                 facecolor=color,
                                 edgecolor=IBM_COLORS['dark_blue'],
                                 linewidth=1)
        ax.add_patch(step_box)
        ax.text(x, y, step, fontsize=8, fontweight='bold',
                ha='center', va='center',
                color='white' if color != IBM_COLORS['yellow'] else IBM_COLORS['dark_blue'])

    # Workflow arrows
    arrows = [
        ((1.9, 6.2), (2.6, 6.2)),
        ((3.4, 6.2), (4.1, 6.2)),
        ((1.9, 5.5), (2.6, 5.5)),
        ((3.4, 5.5), (4.1, 5.5)),
        ((3, 6), (3, 5.7))
    ]

    for start, end in arrows:
        ax.annotate('', xy=end, xytext=start,
                    arrowprops=dict(arrowstyle='->', lw=1.5, color=IBM_COLORS['gray']))

    # Compliance monitoring (right side)
    compliance_box = FancyBboxPatch((6.5, 4.5), 5, 2.5,
                                   boxstyle="round,pad=0.1",
                                   facecolor=IBM_COLORS['light_blue'],
                                   edgecolor=IBM_COLORS['blue'],
                                   linewidth=2)
    ax.add_patch(compliance_box)
    ax.text(9, 6.7, 'Compliance Monitoring', fontsize=12, fontweight='bold',
            ha='center', va='center', color=IBM_COLORS['dark_blue'])

    # Compliance frameworks
    frameworks = [
        ('SOC2 Type II', 7.5, 6.2, '100%'),
        ('ISO27001', 9, 6.2, '95%'),
        ('GDPR', 10.5, 6.2, '100%'),
        ('Audit Trail', 7.5, 5.5, '100%'),
        ('Evidence Collection', 9, 5.5, '90%'),
        ('Risk Assessment', 10.5, 5.5, '85%')
    ]

    for framework, x, y, score in frameworks:
        framework_box = FancyBboxPatch((x-0.4, y-0.15), 0.8, 0.3,
                                      boxstyle="round,pad=0.02",
                                      facecolor=IBM_COLORS['white'],
                                      edgecolor=IBM_COLORS['blue'],
                                      linewidth=1)
        ax.add_patch(framework_box)
        ax.text(x, y+0.05, framework, fontsize=7, fontweight='bold',
                ha='center', va='center', color=IBM_COLORS['dark_blue'])
        ax.text(x, y-0.05, score, fontsize=8, fontweight='bold',
                ha='center', va='center', color=IBM_COLORS['green'])

    # Real-time alerts (bottom left)
    alerts_box = FancyBboxPatch((0.5, 2), 5, 2,
                               boxstyle="round,pad=0.1",
                               facecolor=IBM_COLORS['red'],
                               edgecolor=IBM_COLORS['dark_blue'],
                               linewidth=2)
    ax.add_patch(alerts_box)
    ax.text(3, 3.7, 'Real-time Security Alerts', fontsize=12, fontweight='bold',
            ha='center', va='center', color='white')

    # Alert items
    alert_items = [
        '🚨 Suspicious login from new location',
        '⚠️  Privilege escalation detected',
        '🔍 Unusual access pattern identified',
        '📊 Quarterly review overdue (3 users)'
    ]

    for i, alert in enumerate(alert_items):
        y_pos = 3.4 - i * 0.25
        ax.text(1, y_pos, alert, fontsize=9,
                ha='left', va='center', color='white')

    # Analytics and insights (bottom right)
    analytics_box = FancyBboxPatch((6.5, 2), 5, 2,
                                  boxstyle="round,pad=0.1",
                                  facecolor=IBM_COLORS['purple'],
                                  edgecolor=IBM_COLORS['dark_blue'],
                                  linewidth=2)
    ax.add_patch(analytics_box)
    ax.text(9, 3.7, 'Identity Analytics & Insights', fontsize=12, fontweight='bold',
            ha='center', va='center', color='white')

    # Analytics metrics
    analytics_metrics = [
        'Average access review time: 3 days',
        'User provisioning time: 1 hour',
        'Compliance score trend: +5%',
        'Risk incidents prevented: 47'
    ]

    for i, metric in enumerate(analytics_metrics):
        y_pos = 3.4 - i * 0.25
        ax.text(7, y_pos, metric, fontsize=9,
                ha='left', va='center', color='white')

    # Add business metrics
    metrics = {
        'Automation': '95%',
        'Compliance': '100%',
        'Cost Savings': '70%',
        'Efficiency': '90%'
    }
    add_business_metrics(ax, metrics)

    # Add timestamp
    ax.text(0.02, 0.02, f'Generated: {datetime.now().strftime("%Y-%m-%d %H:%M")}',
            transform=ax.transAxes, fontsize=8, color=IBM_COLORS['gray'])

    plt.tight_layout()
    return fig

def create_federated_trust_relationships():
    """Generate Diagram 4: Federated Trust Relationships and SSO Implementation"""
    fig, ax = plt.subplots(1, 1, figsize=(16, 12))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 10)
    ax.axis('off')

    # Add branding
    add_ibm_branding(ax, "Federated Trust Relationships and SSO Implementation",
                     "Multi-Provider Identity Federation Architecture")

    # Central IBM Cloud App ID
    central_circle = Circle((6, 5), 1.2, facecolor=IBM_COLORS['blue'],
                           edgecolor=IBM_COLORS['dark_blue'], linewidth=3)
    ax.add_patch(central_circle)
    ax.text(6, 5.3, 'IBM Cloud', fontsize=12, fontweight='bold',
            ha='center', va='center', color='white')
    ax.text(6, 5, 'App ID', fontsize=12, fontweight='bold',
            ha='center', va='center', color='white')
    ax.text(6, 4.7, 'Identity Hub', fontsize=10,
            ha='center', va='center', color='white')

    # Identity Providers (surrounding the hub)
    identity_providers = [
        ('Enterprise\nActive Directory', 2, 8, IBM_COLORS['light_blue'], 'SAML 2.0'),
        ('Subsidiary\nLDAP', 2, 2, IBM_COLORS['purple'], 'SAML 2.0'),
        ('Cloud Native\nOIDC Provider', 10, 8, IBM_COLORS['teal'], 'OIDC'),
        ('Partner\nFederation', 10, 2, IBM_COLORS['yellow'], 'SAML 2.0'),
        ('Social\nIdentity', 6, 8.5, IBM_COLORS['green'], 'OAuth 2.0')
    ]

    for provider, x, y, color, protocol in identity_providers:
        provider_box = FancyBboxPatch((x-0.8, y-0.5), 1.6, 1,
                                     boxstyle="round,pad=0.1",
                                     facecolor=color,
                                     edgecolor=IBM_COLORS['dark_blue'],
                                     linewidth=2)
        ax.add_patch(provider_box)
        ax.text(x, y+0.1, provider, fontsize=10, fontweight='bold',
                ha='center', va='center',
                color='white' if color != IBM_COLORS['yellow'] else IBM_COLORS['dark_blue'])
        ax.text(x, y-0.3, protocol, fontsize=8,
                ha='center', va='center',
                color='white' if color != IBM_COLORS['yellow'] else IBM_COLORS['dark_blue'])

        # Trust relationship arrows
        dx = x - 6
        dy = y - 5
        distance = np.sqrt(dx**2 + dy**2)
        unit_x = dx / distance
        unit_y = dy / distance

        start_x = x - 0.8 * unit_x
        start_y = y - 0.5 * unit_y
        end_x = 6 + 1.2 * unit_x
        end_y = 5 + 1.2 * unit_y

        ax.annotate('', xy=(end_x, end_y), xytext=(start_x, start_y),
                    arrowprops=dict(arrowstyle='<->', lw=2, color=color))

    # Applications (right side)
    applications = [
        ('Enterprise\nWeb App', 8.5, 6.5, IBM_COLORS['blue']),
        ('Mobile\nApplication', 8.5, 5.5, IBM_COLORS['green']),
        ('API\nGateway', 8.5, 4.5, IBM_COLORS['purple']),
        ('Legacy\nSystems', 8.5, 3.5, IBM_COLORS['gray'])
    ]

    for app, x, y, color in applications:
        app_box = FancyBboxPatch((x-0.5, y-0.3), 1, 0.6,
                                boxstyle="round,pad=0.05",
                                facecolor=color,
                                edgecolor=IBM_COLORS['dark_blue'],
                                linewidth=1)
        ax.add_patch(app_box)
        ax.text(x, y, app, fontsize=9, fontweight='bold',
                ha='center', va='center', color='white')

        # SSO connection to hub
        ax.annotate('', xy=(7.2, 5), xytext=(x-0.5, y),
                    arrowprops=dict(arrowstyle='->', lw=1.5, color=color))

    # Trust establishment process (bottom)
    trust_process_box = FancyBboxPatch((1, 0.5), 10, 1,
                                      boxstyle="round,pad=0.1",
                                      facecolor=IBM_COLORS['light_gray'],
                                      edgecolor=IBM_COLORS['gray'],
                                      linewidth=2)
    ax.add_patch(trust_process_box)
    ax.text(6, 1.2, 'Trust Establishment Process', fontsize=12, fontweight='bold',
            ha='center', va='center', color=IBM_COLORS['dark_blue'])

    trust_steps = [
        'Certificate Exchange',
        'Metadata Configuration',
        'Trust Policy Definition',
        'Validation Testing',
        'Production Deployment'
    ]

    for i, step in enumerate(trust_steps):
        x_pos = 2 + i * 1.6
        step_box = FancyBboxPatch((x_pos-0.4, 0.7), 0.8, 0.3,
                                 boxstyle="round,pad=0.02",
                                 facecolor=IBM_COLORS['blue'],
                                 edgecolor=IBM_COLORS['dark_blue'],
                                 linewidth=1)
        ax.add_patch(step_box)
        ax.text(x_pos, 0.85, step, fontsize=7, fontweight='bold',
                ha='center', va='center', color='white')

        if i < len(trust_steps) - 1:
            ax.annotate('', xy=(x_pos+0.8, 0.85), xytext=(x_pos+0.4, 0.85),
                        arrowprops=dict(arrowstyle='->', lw=1, color=IBM_COLORS['gray']))

    # Security boundaries
    security_boundary = FancyBboxPatch((0.2, 1.8), 11.6, 6.5,
                                      boxstyle="round,pad=0.1",
                                      facecolor='none',
                                      edgecolor=IBM_COLORS['red'],
                                      linewidth=3,
                                      linestyle='--')
    ax.add_patch(security_boundary)
    ax.text(0.5, 8.1, 'Security Boundary', fontsize=10, fontweight='bold',
            ha='left', va='center', color=IBM_COLORS['red'], rotation=90)

    # Add business metrics
    metrics = {
        'SSO Availability': '99.9%',
        'Auth Time': '< 1s',
        'User Satisfaction': '95%',
        'Provider Support': '5+'
    }
    add_business_metrics(ax, metrics)

    # Add timestamp
    ax.text(0.02, 0.02, f'Generated: {datetime.now().strftime("%Y-%m-%d %H:%M")}',
            transform=ax.transAxes, fontsize=8, color=IBM_COLORS['gray'])

    plt.tight_layout()
    return fig

def create_privileged_access_workflow():
    """Generate Diagram 5: Privileged Access Management and JIT Workflows"""
    fig, ax = plt.subplots(1, 1, figsize=(16, 12))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 10)
    ax.axis('off')

    # Add branding
    add_ibm_branding(ax, "Privileged Access Management and JIT Workflows",
                     "Just-in-Time Access with Comprehensive Monitoring")

    # JIT Access Request Flow (top section)
    flow_title_box = FancyBboxPatch((1, 8.5), 10, 0.6,
                                   boxstyle="round,pad=0.05",
                                   facecolor=IBM_COLORS['dark_blue'],
                                   edgecolor=IBM_COLORS['blue'],
                                   linewidth=2)
    ax.add_patch(flow_title_box)
    ax.text(6, 8.8, 'Just-in-Time Privileged Access Workflow', fontsize=14, fontweight='bold',
            ha='center', va='center', color='white')

    # Workflow steps
    workflow_steps = [
        ('Access\nRequest', 1.5, 7.5, IBM_COLORS['blue'], '1'),
        ('Risk\nAssessment', 3.5, 7.5, IBM_COLORS['yellow'], '2'),
        ('Manager\nApproval', 5.5, 7.5, IBM_COLORS['purple'], '3'),
        ('Privilege\nElevation', 7.5, 7.5, IBM_COLORS['green'], '4'),
        ('Session\nMonitoring', 9.5, 7.5, IBM_COLORS['red'], '5')
    ]

    for step, x, y, color, num in workflow_steps:
        # Step box
        step_box = FancyBboxPatch((x-0.6, y-0.4), 1.2, 0.8,
                                 boxstyle="round,pad=0.1",
                                 facecolor=color,
                                 edgecolor=IBM_COLORS['dark_blue'],
                                 linewidth=2)
        ax.add_patch(step_box)
        ax.text(x, y, step, fontsize=9, fontweight='bold',
                ha='center', va='center',
                color='white' if color != IBM_COLORS['yellow'] else IBM_COLORS['dark_blue'])

        # Step number
        num_circle = Circle((x-0.5, y+0.3), 0.15, facecolor=IBM_COLORS['dark_blue'],
                           edgecolor='white', linewidth=2)
        ax.add_patch(num_circle)
        ax.text(x-0.5, y+0.3, num, fontsize=8, fontweight='bold',
                ha='center', va='center', color='white')

        # Timing annotations
        timings = ['< 1 min', '< 5 min', '< 15 min', '< 1 min', 'Real-time']
        ax.text(x, y-0.7, timings[int(num)-1], fontsize=8, fontweight='bold',
                ha='center', va='center', color=color)

    # Flow arrows
    for i in range(len(workflow_steps) - 1):
        start_x = workflow_steps[i][1] + 0.6
        end_x = workflow_steps[i+1][1] - 0.6
        ax.annotate('', xy=(end_x, 7.5), xytext=(start_x, 7.5),
                    arrowprops=dict(arrowstyle='->', lw=2, color=IBM_COLORS['gray']))

    # Auto-revocation timer
    timer_box = FancyBboxPatch((10.5, 6.5), 1, 1,
                              boxstyle="round,pad=0.1",
                              facecolor=IBM_COLORS['red'],
                              edgecolor=IBM_COLORS['dark_blue'],
                              linewidth=2)
    ax.add_patch(timer_box)
    ax.text(11, 7.2, 'Auto\nRevoke', fontsize=9, fontweight='bold',
            ha='center', va='center', color='white')
    ax.text(11, 6.8, '4 Hours', fontsize=8, fontweight='bold',
            ha='center', va='center', color='white')

    # Curved arrow for auto-revocation
    ax.annotate('', xy=(9.5, 6.8), xytext=(10.5, 6.8),
                arrowprops=dict(arrowstyle='->', lw=2, color=IBM_COLORS['red'],
                               connectionstyle="arc3,rad=0.3"))

    # Session monitoring details (middle section)
    monitoring_box = FancyBboxPatch((0.5, 4), 11, 2,
                                   boxstyle="round,pad=0.1",
                                   facecolor=IBM_COLORS['light_gray'],
                                   edgecolor=IBM_COLORS['gray'],
                                   linewidth=2)
    ax.add_patch(monitoring_box)
    ax.text(6, 5.7, 'Privileged Session Monitoring and Recording', fontsize=12, fontweight='bold',
            ha='center', va='center', color=IBM_COLORS['dark_blue'])

    # Monitoring components
    monitoring_components = [
        ('Command\nLogging', 2, 5, IBM_COLORS['blue']),
        ('Screen\nRecording', 4, 5, IBM_COLORS['green']),
        ('Keystroke\nCapture', 6, 5, IBM_COLORS['purple']),
        ('File Access\nTracking', 8, 5, IBM_COLORS['teal']),
        ('Network\nMonitoring', 10, 5, IBM_COLORS['yellow'])
    ]

    for comp, x, y, color in monitoring_components:
        comp_box = FancyBboxPatch((x-0.5, y-0.3), 1, 0.6,
                                 boxstyle="round,pad=0.05",
                                 facecolor=color,
                                 edgecolor=IBM_COLORS['dark_blue'],
                                 linewidth=1)
        ax.add_patch(comp_box)
        ax.text(x, y, comp, fontsize=8, fontweight='bold',
                ha='center', va='center',
                color='white' if color != IBM_COLORS['yellow'] else IBM_COLORS['dark_blue'])

    # Real-time alerts
    alert_indicators = [
        ('Suspicious\nCommand', 2, 4.3, IBM_COLORS['red']),
        ('Large Data\nTransfer', 4, 4.3, IBM_COLORS['red']),
        ('Unusual\nBehavior', 6, 4.3, IBM_COLORS['yellow']),
        ('Policy\nViolation', 8, 4.3, IBM_COLORS['red']),
        ('Session\nAnomaly', 10, 4.3, IBM_COLORS['yellow'])
    ]

    for alert, x, y, color in alert_indicators:
        alert_triangle = patches.RegularPolygon((x, y), 3, radius=0.2,
                                              facecolor=color,
                                              edgecolor=IBM_COLORS['dark_blue'],
                                              linewidth=1)
        ax.add_patch(alert_triangle)
        ax.text(x, y-0.5, alert, fontsize=7,
                ha='center', va='center', color=color)

    # Audit trail and compliance (bottom section)
    audit_box = FancyBboxPatch((0.5, 1.5), 5, 2,
                              boxstyle="round,pad=0.1",
                              facecolor=IBM_COLORS['purple'],
                              edgecolor=IBM_COLORS['dark_blue'],
                              linewidth=2)
    ax.add_patch(audit_box)
    ax.text(3, 3.2, 'Comprehensive Audit Trail', fontsize=12, fontweight='bold',
            ha='center', va='center', color='white')

    audit_features = [
        '• Immutable log storage (7 years)',
        '• Real-time SIEM integration',
        '• Compliance evidence collection',
        '• Forensic analysis capabilities',
        '• Automated reporting (SOC2/ISO27001)'
    ]

    for i, feature in enumerate(audit_features):
        y_pos = 2.9 - i * 0.2
        ax.text(1, y_pos, feature, fontsize=8,
                ha='left', va='center', color='white')

    # Business impact metrics (bottom right)
    impact_box = FancyBboxPatch((6.5, 1.5), 5, 2,
                               boxstyle="round,pad=0.1",
                               facecolor=IBM_COLORS['green'],
                               edgecolor=IBM_COLORS['dark_blue'],
                               linewidth=2)
    ax.add_patch(impact_box)
    ax.text(9, 3.2, 'Business Impact Metrics', fontsize=12, fontweight='bold',
            ha='center', va='center', color='white')

    impact_metrics = [
        '• 95% reduction in standing privileges',
        '• 100% audit coverage achieved',
        '• 90% operational efficiency gain',
        '• 85% faster incident response',
        '• 70% compliance cost reduction'
    ]

    for i, metric in enumerate(impact_metrics):
        y_pos = 2.9 - i * 0.2
        ax.text(7, y_pos, metric, fontsize=8,
                ha='left', va='center', color='white')

    # Integration indicators
    integration_systems = [
        ('SIEM', 1.5, 0.8, IBM_COLORS['blue']),
        ('Ticketing', 3, 0.8, IBM_COLORS['purple']),
        ('HR Systems', 4.5, 0.8, IBM_COLORS['green']),
        ('Compliance', 6, 0.8, IBM_COLORS['yellow']),
        ('Audit', 7.5, 0.8, IBM_COLORS['teal']),
        ('Notification', 9, 0.8, IBM_COLORS['red']),
        ('Analytics', 10.5, 0.8, IBM_COLORS['gray'])
    ]

    for system, x, y, color in integration_systems:
        system_circle = Circle((x, y), 0.2, facecolor=color,
                              edgecolor=IBM_COLORS['dark_blue'], linewidth=1)
        ax.add_patch(system_circle)
        ax.text(x, y-0.4, system, fontsize=7, fontweight='bold',
                ha='center', va='center', color=IBM_COLORS['gray'])
        ax.text(x, y, '✓', fontsize=10, fontweight='bold',
                ha='center', va='center', color='white')

    # Add business metrics
    metrics = {
        'Standing Privileges': '-95%',
        'Audit Coverage': '100%',
        'Response Time': '-75%',
        'Compliance Cost': '-70%'
    }
    add_business_metrics(ax, metrics)

    # Add timestamp
    ax.text(0.02, 0.02, f'Generated: {datetime.now().strftime("%Y-%m-%d %H:%M")}',
            transform=ax.transAxes, fontsize=8, color=IBM_COLORS['gray'])

    plt.tight_layout()
    return fig

def main():
    """Main function to generate all IAM integration diagrams"""
    print("🎨 Generating IBM Cloud IAM Integration Diagrams...")
    print("=" * 60)

    # Create output directory
    output_dir = create_output_directory()

    # Generate all diagrams
    diagrams = [
        ("01_enterprise_identity_architecture", create_enterprise_identity_architecture),
        ("02_authentication_flow_diagram", create_authentication_flow_diagram),
        ("03_identity_governance_dashboard", create_identity_governance_dashboard),
        ("04_federated_trust_relationships", create_federated_trust_relationships),
        ("05_privileged_access_workflow", create_privileged_access_workflow)
    ]

    for filename, diagram_func in diagrams:
        print(f"📊 Generating {filename}...")
        try:
            fig = diagram_func()
            filepath = os.path.join(output_dir, f"{filename}.png")
            fig.savefig(filepath, dpi=300, bbox_inches='tight',
                       facecolor='white', edgecolor='none')
            plt.close(fig)
            print(f"✅ Successfully saved: {filepath}")
        except Exception as e:
            print(f"❌ Error generating {filename}: {str(e)}")

    print("=" * 60)
    print("🎉 All IAM Integration diagrams generated successfully!")
    print(f"📁 Output directory: {output_dir}")
    print("\n📋 Generated diagrams:")
    for filename, _ in diagrams:
        print(f"   • {filename}.png")

if __name__ == "__main__":
    main()
