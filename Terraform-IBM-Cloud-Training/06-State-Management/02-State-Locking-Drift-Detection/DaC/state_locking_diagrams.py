#!/usr/bin/env python3
"""
Terraform State Locking and Drift Detection Diagrams Generator
Subtopic 6.2: State Locking and Drift Detection

This script generates 5 professional diagrams for advanced state management:
1. State Locking Mechanism Overview
2. Drift Detection Architecture
3. Conflict Resolution Workflow
4. Automated Remediation Process
5. Enterprise Monitoring Dashboard

All diagrams are generated at 300 DPI with IBM brand compliance.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, Circle, Rectangle, Arrow, Polygon
import numpy as np
import os

# IBM Brand Colors
IBM_BLUE = '#1261FE'
IBM_DARK_BLUE = '#0F62FE'
IBM_LIGHT_BLUE = '#4589FF'
IBM_GRAY = '#525252'
IBM_LIGHT_GRAY = '#F4F4F4'
IBM_GREEN = '#24A148'
IBM_ORANGE = '#FF832B'
IBM_RED = '#DA1E28'
IBM_PURPLE = '#8A3FFC'
IBM_YELLOW = '#F1C21B'

# Create output directory
os.makedirs('generated_diagrams', exist_ok=True)

def setup_diagram_style():
    """Setup consistent diagram styling"""
    plt.style.use('default')
    return {
        'title_size': 16,
        'label_size': 12,
        'text_size': 10,
        'small_text': 8,
        'line_width': 2,
        'dpi': 300
    }

def create_figure(title, figsize=(14, 10)):
    """Create a new figure with consistent styling"""
    fig, ax = plt.subplots(figsize=figsize, dpi=300)
    ax.set_xlim(0, 16)
    ax.set_ylim(0, 12)
    ax.set_aspect('equal')
    ax.axis('off')
    
    # Add title
    fig.suptitle(title, fontsize=16, fontweight='bold', y=0.95)
    
    return fig, ax

def add_ibm_branding(ax):
    """Add IBM branding elements to diagram"""
    # IBM logo placeholder
    logo_rect = Rectangle((0.2, 11.2), 1.5, 0.6, facecolor=IBM_BLUE, alpha=0.8)
    ax.add_patch(logo_rect)
    ax.text(0.95, 11.5, 'IBM', fontsize=12, fontweight='bold', 
            color='white', ha='center', va='center')

def diagram_1_state_locking_mechanism():
    """Figure 6.2.1: State Locking Mechanism Overview"""
    fig, ax = create_figure('Figure 6.2.1: State Locking Mechanism Overview')
    style = setup_diagram_style()
    
    # Lock acquisition flow
    steps = [
        (2, 9, 'Request\nLock', IBM_BLUE),
        (5, 9, 'Check\nAvailability', IBM_ORANGE),
        (8, 9, 'Acquire\nLock', IBM_GREEN),
        (11, 9, 'Execute\nOperation', IBM_PURPLE),
        (14, 9, 'Release\nLock', IBM_GREEN)
    ]
    
    # Draw lock acquisition flow
    for i, (x, y, title, color) in enumerate(steps):
        # Step circle
        circle = Circle((x, y), 0.8, facecolor=color, alpha=0.8, edgecolor=color)
        ax.add_patch(circle)
        ax.text(x, y, title, fontsize=style['small_text'], fontweight='bold',
                ha='center', va='center', color='white')
        
        # Arrow to next step
        if i < len(steps) - 1:
            arrow = patches.FancyArrowPatch((x + 0.8, y), (steps[i+1][0] - 0.8, y),
                                          arrowstyle='->', mutation_scale=20,
                                          color=IBM_GRAY, linewidth=2)
            ax.add_patch(arrow)
    
    # Lock table representation
    lock_table = FancyBboxPatch((3, 6), 10, 2, boxstyle="round,pad=0.1",
                               facecolor=IBM_LIGHT_BLUE, alpha=0.3, edgecolor=IBM_BLUE, linewidth=2)
    ax.add_patch(lock_table)
    ax.text(8, 7.5, 'DISTRIBUTED LOCK TABLE', fontsize=style['label_size'], fontweight='bold',
            ha='center', va='center', color=IBM_BLUE)
    ax.text(8, 7, 'IBM Cloudant / DynamoDB Compatible', fontsize=style['text_size'],
            ha='center', va='center')
    
    # Lock record structure
    lock_fields = [
        'LockID: terraform-state-bucket/infrastructure/terraform.tfstate',
        'Operation: OperationTypeApply',
        'Who: operator@company.com',
        'Created: 2024-09-14T10:30:00Z',
        'Version: 1.5.0'
    ]
    
    for i, field in enumerate(lock_fields):
        ax.text(8, 6.6 - i * 0.15, field, fontsize=style['small_text'],
                ha='center', va='center', fontfamily='monospace')
    
    # Concurrent access scenarios
    scenario_y = 4
    
    # Scenario 1: Successful lock
    success_rect = FancyBboxPatch((1, scenario_y), 6, 1.5, boxstyle="round,pad=0.1",
                                 facecolor=IBM_GREEN, alpha=0.2, edgecolor=IBM_GREEN)
    ax.add_patch(success_rect)
    ax.text(4, scenario_y + 1, 'SUCCESSFUL LOCK ACQUISITION', fontsize=style['text_size'], 
            fontweight='bold', ha='center', va='center', color=IBM_GREEN)
    ax.text(4, scenario_y + 0.6, '✓ Lock available', fontsize=style['small_text'], ha='center', va='center')
    ax.text(4, scenario_y + 0.3, '✓ Operation proceeds', fontsize=style['small_text'], ha='center', va='center')
    
    # Scenario 2: Lock conflict
    conflict_rect = FancyBboxPatch((9, scenario_y), 6, 1.5, boxstyle="round,pad=0.1",
                                  facecolor=IBM_RED, alpha=0.2, edgecolor=IBM_RED)
    ax.add_patch(conflict_rect)
    ax.text(12, scenario_y + 1, 'LOCK CONFLICT DETECTED', fontsize=style['text_size'], 
            fontweight='bold', ha='center', va='center', color=IBM_RED)
    ax.text(12, scenario_y + 0.6, '✗ Lock held by another user', fontsize=style['small_text'], ha='center', va='center')
    ax.text(12, scenario_y + 0.3, '✗ Operation blocked/queued', fontsize=style['small_text'], ha='center', va='center')
    
    # Lock timeout configuration
    timeout_rect = FancyBboxPatch((4, 1.5), 8, 1.5, boxstyle="round,pad=0.1",
                                 facecolor=IBM_YELLOW, alpha=0.2, edgecolor=IBM_ORANGE)
    ax.add_patch(timeout_rect)
    ax.text(8, 2.7, 'LOCK TIMEOUT CONFIGURATION', fontsize=style['text_size'], 
            fontweight='bold', ha='center', va='center', color=IBM_ORANGE)
    ax.text(8, 2.3, 'Timeout: 10 minutes | Retry: 3 attempts | Delay: 5 seconds', 
            fontsize=style['small_text'], ha='center', va='center')
    ax.text(8, 1.9, 'Emergency unlock: terraform force-unlock LOCK_ID', 
            fontsize=style['small_text'], ha='center', va='center', fontfamily='monospace')
    
    add_ibm_branding(ax)
    plt.tight_layout()
    plt.savefig('generated_diagrams/figure_6_2_1_state_locking_mechanism.png', dpi=300, bbox_inches='tight')
    plt.close()

def diagram_2_drift_detection_architecture():
    """Figure 6.2.2: Drift Detection Architecture"""
    fig, ax = create_figure('Figure 6.2.2: Drift Detection Architecture')
    style = setup_diagram_style()
    
    # Infrastructure layer
    infra_rect = FancyBboxPatch((1, 8.5), 14, 2, boxstyle="round,pad=0.1",
                               facecolor=IBM_LIGHT_GRAY, alpha=0.8, edgecolor=IBM_GRAY, linewidth=2)
    ax.add_patch(infra_rect)
    ax.text(8, 9.8, 'ACTUAL INFRASTRUCTURE', fontsize=style['label_size'], fontweight='bold',
            ha='center', va='center')
    ax.text(8, 9.4, 'IBM Cloud Resources • Manual Changes • External Automation', 
            fontsize=style['text_size'], ha='center', va='center')
    
    # Infrastructure components
    components = [
        (3, 9, 'VPC'),
        (6, 9, 'VSI'),
        (9, 9, 'COS'),
        (12, 9, 'Security\nGroups')
    ]
    
    for x, y, comp in components:
        comp_rect = FancyBboxPatch((x - 0.7, y - 0.3), 1.4, 0.6, boxstyle="round,pad=0.05",
                                  facecolor='white', alpha=0.9, edgecolor=IBM_GRAY)
        ax.add_patch(comp_rect)
        ax.text(x, y, comp, fontsize=style['small_text'], fontweight='bold',
                ha='center', va='center')
    
    # Terraform state layer
    state_rect = FancyBboxPatch((1, 6), 14, 1.5, boxstyle="round,pad=0.1",
                               facecolor=IBM_BLUE, alpha=0.8, edgecolor=IBM_DARK_BLUE, linewidth=2)
    ax.add_patch(state_rect)
    ax.text(8, 7, 'TERRAFORM STATE', fontsize=style['label_size'], fontweight='bold',
            ha='center', va='center', color='white')
    ax.text(8, 6.6, 'Expected Infrastructure Configuration', fontsize=style['text_size'],
            ha='center', va='center', color='white')
    ax.text(8, 6.2, 'Remote Backend: IBM Cloud Object Storage', fontsize=style['small_text'],
            ha='center', va='center', color='white')
    
    # Drift detection engine
    detection_rect = FancyBboxPatch((4, 3.5), 8, 2, boxstyle="round,pad=0.1",
                                   facecolor=IBM_PURPLE, alpha=0.8, edgecolor=IBM_PURPLE, linewidth=2)
    ax.add_patch(detection_rect)
    ax.text(8, 4.8, 'DRIFT DETECTION ENGINE', fontsize=style['label_size'], fontweight='bold',
            ha='center', va='center', color='white')
    ax.text(8, 4.4, 'IBM Cloud Functions', fontsize=style['text_size'],
            ha='center', va='center', color='white')
    ax.text(8, 4, 'Scheduled: Every 6 hours', fontsize=style['small_text'],
            ha='center', va='center', color='white')
    ax.text(8, 3.7, 'Command: terraform plan -detailed-exitcode', fontsize=style['small_text'],
            ha='center', va='center', color='white', fontfamily='monospace')
    
    # Comparison arrows
    up_arrow = patches.FancyArrowPatch((8, 6), (8, 5.5), arrowstyle='<->', mutation_scale=25,
                                     color=IBM_ORANGE, linewidth=3)
    ax.add_patch(up_arrow)
    ax.text(8.5, 5.75, 'Compare', fontsize=style['small_text'], fontweight='bold',
            ha='left', va='center', color=IBM_ORANGE)
    
    down_arrow = patches.FancyArrowPatch((8, 8.5), (8, 7.5), arrowstyle='<->', mutation_scale=25,
                                       color=IBM_ORANGE, linewidth=3)
    ax.add_patch(down_arrow)
    ax.text(8.5, 8, 'Validate', fontsize=style['small_text'], fontweight='bold',
            ha='left', va='center', color=IBM_ORANGE)
    
    # Alert and monitoring layer
    alert_rect = FancyBboxPatch((1, 1), 14, 2, boxstyle="round,pad=0.1",
                               facecolor=IBM_GREEN, alpha=0.2, edgecolor=IBM_GREEN, linewidth=2)
    ax.add_patch(alert_rect)
    ax.text(8, 2.5, 'MONITORING & ALERTING', fontsize=style['label_size'], fontweight='bold',
            ha='center', va='center', color=IBM_GREEN)
    
    # Alert channels
    channels = [
        (3, 1.8, 'Slack\nNotifications'),
        (6, 1.8, 'Email\nAlerts'),
        (9, 1.8, 'Dashboard\nMetrics'),
        (12, 1.8, 'Incident\nTickets')
    ]
    
    for x, y, channel in channels:
        channel_rect = FancyBboxPatch((x - 0.8, y - 0.4), 1.6, 0.8, boxstyle="round,pad=0.05",
                                     facecolor=IBM_GREEN, alpha=0.7, edgecolor=IBM_GREEN)
        ax.add_patch(channel_rect)
        ax.text(x, y, channel, fontsize=style['small_text'], fontweight='bold',
                ha='center', va='center', color='white')
    
    # Detection flow arrows
    for x, y, _ in channels:
        arrow = patches.FancyArrowPatch((8, 3.5), (x, y + 0.4), arrowstyle='->', mutation_scale=15,
                                      color=IBM_GREEN, linewidth=2)
        ax.add_patch(arrow)
    
    add_ibm_branding(ax)
    plt.tight_layout()
    plt.savefig('generated_diagrams/figure_6_2_2_drift_detection_architecture.png', dpi=300, bbox_inches='tight')
    plt.close()

def diagram_3_conflict_resolution_workflow():
    """Figure 6.2.3: Conflict Resolution Workflow"""
    fig, ax = create_figure('Figure 6.2.3: Conflict Resolution Workflow')
    style = setup_diagram_style()
    
    # Workflow stages
    stages = [
        (2, 9, 'Conflict\nDetected', IBM_RED, 'Lock held by\nanother user'),
        (5, 9, 'Assessment', IBM_ORANGE, 'Evaluate urgency\nand impact'),
        (8, 9, 'Coordination', IBM_BLUE, 'Contact lock\nholder'),
        (11, 9, 'Resolution', IBM_GREEN, 'Wait or force\nunlock'),
        (14, 9, 'Validation', IBM_PURPLE, 'Verify state\nintegrity')
    ]
    
    # Draw workflow stages
    for i, (x, y, title, color, desc) in enumerate(stages):
        # Stage circle
        circle = Circle((x, y), 1, facecolor=color, alpha=0.8, edgecolor=color)
        ax.add_patch(circle)
        ax.text(x, y + 0.2, title, fontsize=style['small_text'], fontweight='bold',
                ha='center', va='center', color='white')
        ax.text(x, y - 0.2, desc, fontsize=style['small_text'],
                ha='center', va='center', color='white')
        
        # Arrow to next stage
        if i < len(stages) - 1:
            arrow = patches.FancyArrowPatch((x + 1, y), (stages[i+1][0] - 1, y),
                                          arrowstyle='->', mutation_scale=20,
                                          color=IBM_GRAY, linewidth=2)
            ax.add_patch(arrow)
    
    # Decision matrix
    matrix_rect = FancyBboxPatch((2, 5.5), 12, 2.5, boxstyle="round,pad=0.1",
                                facecolor=IBM_LIGHT_GRAY, alpha=0.8, edgecolor=IBM_GRAY, linewidth=2)
    ax.add_patch(matrix_rect)
    ax.text(8, 7.5, 'CONFLICT RESOLUTION DECISION MATRIX', fontsize=style['label_size'], 
            fontweight='bold', ha='center', va='center')
    
    # Decision scenarios
    scenarios = [
        ('Low Priority + Responsive User', 'Wait for completion', IBM_GREEN),
        ('High Priority + Responsive User', 'Coordinate immediate action', IBM_ORANGE),
        ('Low Priority + Unresponsive User', 'Wait with timeout', IBM_YELLOW),
        ('High Priority + Unresponsive User', 'Emergency force unlock', IBM_RED)
    ]
    
    for i, (scenario, action, color) in enumerate(scenarios):
        y_pos = 7.1 - i * 0.3
        ax.text(3, y_pos, f'• {scenario}:', fontsize=style['small_text'], fontweight='bold',
                ha='left', va='center')
        ax.text(9, y_pos, action, fontsize=style['small_text'],
                ha='left', va='center', color=color)
    
    # Emergency procedures
    emergency_rect = FancyBboxPatch((2, 2.5), 12, 2.5, boxstyle="round,pad=0.1",
                                   facecolor=IBM_RED, alpha=0.1, edgecolor=IBM_RED, linewidth=2)
    ax.add_patch(emergency_rect)
    ax.text(8, 4.5, 'EMERGENCY UNLOCK PROCEDURES', fontsize=style['label_size'], 
            fontweight='bold', ha='center', va='center', color=IBM_RED)
    
    # Emergency steps
    emergency_steps = [
        '1. Verify lock holder is truly unresponsive',
        '2. Assess business impact and urgency',
        '3. Get approval from team lead or manager',
        '4. Execute: terraform force-unlock LOCK_ID',
        '5. Verify state consistency with terraform plan',
        '6. Document incident and notify team'
    ]
    
    for i, step in enumerate(emergency_steps):
        y_pos = 4.1 - i * 0.2
        ax.text(8, y_pos, step, fontsize=style['small_text'],
                ha='center', va='center')
    
    # Communication channels
    comm_rect = FancyBboxPatch((2, 0.5), 12, 1.5, boxstyle="round,pad=0.1",
                              facecolor=IBM_BLUE, alpha=0.2, edgecolor=IBM_BLUE, linewidth=2)
    ax.add_patch(comm_rect)
    ax.text(8, 1.7, 'TEAM COMMUNICATION CHANNELS', fontsize=style['label_size'], 
            fontweight='bold', ha='center', va='center', color=IBM_BLUE)
    
    # Communication methods
    comm_methods = [
        (4, 1.2, 'Slack\n#infrastructure'),
        (6.5, 1.2, 'Email\nteam@company.com'),
        (9, 1.2, 'Phone\nOn-call rotation'),
        (11.5, 1.2, 'Incident\nManagement')
    ]
    
    for x, y, method in comm_methods:
        method_rect = FancyBboxPatch((x - 0.7, y - 0.3), 1.4, 0.6, boxstyle="round,pad=0.05",
                                    facecolor=IBM_BLUE, alpha=0.7, edgecolor=IBM_BLUE)
        ax.add_patch(method_rect)
        ax.text(x, y, method, fontsize=style['small_text'], fontweight='bold',
                ha='center', va='center', color='white')
    
    add_ibm_branding(ax)
    plt.tight_layout()
    plt.savefig('generated_diagrams/figure_6_2_3_conflict_resolution_workflow.png', dpi=300, bbox_inches='tight')
    plt.close()

def diagram_4_automated_remediation():
    """Figure 6.2.4: Automated Remediation Process"""
    fig, ax = create_figure('Figure 6.2.4: Automated Remediation Process')
    style = setup_diagram_style()
    
    # Remediation pipeline
    pipeline_stages = [
        (2, 9, 'Drift\nDetected', IBM_RED),
        (5, 9, 'Severity\nAnalysis', IBM_ORANGE),
        (8, 9, 'Decision\nGate', IBM_BLUE),
        (11, 9, 'Remediation\nAction', IBM_GREEN),
        (14, 9, 'Validation', IBM_PURPLE)
    ]
    
    # Draw pipeline
    for i, (x, y, title, color) in enumerate(pipeline_stages):
        circle = Circle((x, y), 0.8, facecolor=color, alpha=0.8, edgecolor=color)
        ax.add_patch(circle)
        ax.text(x, y, title, fontsize=style['small_text'], fontweight='bold',
                ha='center', va='center', color='white')
        
        if i < len(pipeline_stages) - 1:
            arrow = patches.FancyArrowPatch((x + 0.8, y), (pipeline_stages[i+1][0] - 0.8, y),
                                          arrowstyle='->', mutation_scale=20,
                                          color=IBM_GRAY, linewidth=2)
            ax.add_patch(arrow)
    
    # Severity analysis matrix
    severity_rect = FancyBboxPatch((1, 6.5), 6, 2, boxstyle="round,pad=0.1",
                                  facecolor=IBM_ORANGE, alpha=0.2, edgecolor=IBM_ORANGE, linewidth=2)
    ax.add_patch(severity_rect)
    ax.text(4, 8, 'SEVERITY ANALYSIS', fontsize=style['text_size'], fontweight='bold',
            ha='center', va='center', color=IBM_ORANGE)
    
    severity_factors = [
        'Security Groups: +3 points',
        'Database Resources: +4 points',
        'Destroy Operations: +5 points',
        'Production Environment: +2 points'
    ]
    
    for i, factor in enumerate(severity_factors):
        ax.text(4, 7.6 - i * 0.2, f'• {factor}', fontsize=style['small_text'],
                ha='center', va='center')
    
    # Decision logic
    decision_rect = FancyBboxPatch((9, 6.5), 6, 2, boxstyle="round,pad=0.1",
                                  facecolor=IBM_BLUE, alpha=0.2, edgecolor=IBM_BLUE, linewidth=2)
    ax.add_patch(decision_rect)
    ax.text(12, 8, 'DECISION LOGIC', fontsize=style['text_size'], fontweight='bold',
            ha='center', va='center', color=IBM_BLUE)
    
    decision_rules = [
        'Score ≤ 3: Auto-remediate',
        'Score 4-6: Request approval',
        'Score 7-10: Manual review',
        'Emergency: Override rules'
    ]
    
    for i, rule in enumerate(decision_rules):
        ax.text(12, 7.6 - i * 0.2, f'• {rule}', fontsize=style['small_text'],
                ha='center', va='center')
    
    # Remediation paths
    auto_path = FancyBboxPatch((1, 4), 4.5, 2, boxstyle="round,pad=0.1",
                              facecolor=IBM_GREEN, alpha=0.2, edgecolor=IBM_GREEN, linewidth=2)
    ax.add_patch(auto_path)
    ax.text(3.25, 5.5, 'AUTOMATED PATH', fontsize=style['text_size'], fontweight='bold',
            ha='center', va='center', color=IBM_GREEN)
    
    auto_steps = [
        '1. Execute terraform apply',
        '2. Verify changes applied',
        '3. Send success notification',
        '4. Update audit log'
    ]
    
    for i, step in enumerate(auto_steps):
        ax.text(3.25, 5.1 - i * 0.2, step, fontsize=style['small_text'],
                ha='center', va='center')
    
    # Manual approval path
    manual_path = FancyBboxPatch((6, 4), 4.5, 2, boxstyle="round,pad=0.1",
                                facecolor=IBM_YELLOW, alpha=0.2, edgecolor=IBM_ORANGE, linewidth=2)
    ax.add_patch(manual_path)
    ax.text(8.25, 5.5, 'APPROVAL PATH', fontsize=style['text_size'], fontweight='bold',
            ha='center', va='center', color=IBM_ORANGE)
    
    approval_steps = [
        '1. Create approval request',
        '2. Notify team leads',
        '3. Wait for approval',
        '4. Execute if approved'
    ]
    
    for i, step in enumerate(approval_steps):
        ax.text(8.25, 5.1 - i * 0.2, step, fontsize=style['small_text'],
                ha='center', va='center')
    
    # Emergency override
    emergency_path = FancyBboxPatch((11.5, 4), 4, 2, boxstyle="round,pad=0.1",
                                   facecolor=IBM_RED, alpha=0.2, edgecolor=IBM_RED, linewidth=2)
    ax.add_patch(emergency_path)
    ax.text(13.5, 5.5, 'EMERGENCY PATH', fontsize=style['text_size'], fontweight='bold',
            ha='center', va='center', color=IBM_RED)
    
    emergency_steps = [
        '1. Override approval',
        '2. Immediate execution',
        '3. Alert stakeholders',
        '4. Post-incident review'
    ]
    
    for i, step in enumerate(emergency_steps):
        ax.text(13.5, 5.1 - i * 0.2, step, fontsize=style['small_text'],
                ha='center', va='center')
    
    # Monitoring and feedback
    feedback_rect = FancyBboxPatch((3, 1.5), 10, 2, boxstyle="round,pad=0.1",
                                  facecolor=IBM_PURPLE, alpha=0.2, edgecolor=IBM_PURPLE, linewidth=2)
    ax.add_patch(feedback_rect)
    ax.text(8, 3, 'CONTINUOUS MONITORING & FEEDBACK', fontsize=style['text_size'], 
            fontweight='bold', ha='center', va='center', color=IBM_PURPLE)
    
    feedback_items = [
        'Success Rate Tracking • Performance Metrics • Error Analysis',
        'Threshold Optimization • Process Improvement • Team Feedback'
    ]
    
    for i, item in enumerate(feedback_items):
        ax.text(8, 2.6 - i * 0.3, item, fontsize=style['small_text'],
                ha='center', va='center')
    
    add_ibm_branding(ax)
    plt.tight_layout()
    plt.savefig('generated_diagrams/figure_6_2_4_automated_remediation.png', dpi=300, bbox_inches='tight')
    plt.close()

def diagram_5_enterprise_monitoring():
    """Figure 6.2.5: Enterprise Monitoring Dashboard"""
    fig, ax = create_figure('Figure 6.2.5: Enterprise Monitoring Dashboard')
    style = setup_diagram_style()
    
    # Dashboard header
    header_rect = FancyBboxPatch((1, 10), 14, 1.5, boxstyle="round,pad=0.1",
                                facecolor=IBM_DARK_BLUE, alpha=0.9, edgecolor=IBM_BLUE, linewidth=2)
    ax.add_patch(header_rect)
    ax.text(8, 10.75, 'TERRAFORM STATE MANAGEMENT DASHBOARD', fontsize=style['label_size'], 
            fontweight='bold', ha='center', va='center', color='white')
    ax.text(8, 10.25, 'Real-time Monitoring • Drift Detection • Performance Metrics', 
            fontsize=style['text_size'], ha='center', va='center', color='white')
    
    # Metrics panels
    panels = [
        (3, 8, 'State Operations\nLast 24h', '247', IBM_BLUE),
        (8, 8, 'Drift Events\nDetected', '12', IBM_ORANGE),
        (13, 8, 'Auto-Remediated\nIssues', '9', IBM_GREEN)
    ]
    
    for x, y, title, value, color in panels:
        panel_rect = FancyBboxPatch((x - 1.5, y - 1), 3, 2, boxstyle="round,pad=0.1",
                                   facecolor=color, alpha=0.8, edgecolor=color)
        ax.add_patch(panel_rect)
        ax.text(x, y + 0.5, title, fontsize=style['small_text'], fontweight='bold',
                ha='center', va='center', color='white')
        ax.text(x, y - 0.3, value, fontsize=20, fontweight='bold',
                ha='center', va='center', color='white')
    
    # Performance chart
    chart_rect = FancyBboxPatch((1, 4.5), 6, 3, boxstyle="round,pad=0.1",
                               facecolor=IBM_LIGHT_GRAY, alpha=0.3, edgecolor=IBM_GRAY)
    ax.add_patch(chart_rect)
    ax.text(4, 7, 'LOCK DURATION TRENDS', fontsize=style['text_size'], fontweight='bold',
            ha='center', va='center')
    
    # Simulated chart data
    x_data = np.linspace(1.5, 6.5, 20)
    y_data = 5.5 + 0.5 * np.sin(x_data) + 0.2 * np.random.randn(20)
    ax.plot(x_data, y_data, color=IBM_BLUE, linewidth=2)
    ax.fill_between(x_data, 5, y_data, alpha=0.3, color=IBM_BLUE)
    
    # Alert status
    alert_rect = FancyBboxPatch((8.5, 4.5), 6, 3, boxstyle="round,pad=0.1",
                               facecolor=IBM_LIGHT_GRAY, alpha=0.3, edgecolor=IBM_GRAY)
    ax.add_patch(alert_rect)
    ax.text(11.5, 7, 'ACTIVE ALERTS', fontsize=style['text_size'], fontweight='bold',
            ha='center', va='center')
    
    alerts = [
        ('High drift rate in prod-vpc', IBM_RED),
        ('Lock timeout in staging', IBM_ORANGE),
        ('Remediation success rate low', IBM_YELLOW)
    ]
    
    for i, (alert, color) in enumerate(alerts):
        alert_y = 6.5 - i * 0.4
        alert_indicator = Circle((9.2, alert_y), 0.1, facecolor=color, alpha=0.8)
        ax.add_patch(alert_indicator)
        ax.text(9.5, alert_y, alert, fontsize=style['small_text'],
                ha='left', va='center')
    
    # Team activity
    activity_rect = FancyBboxPatch((1, 1), 6, 3, boxstyle="round,pad=0.1",
                                  facecolor=IBM_LIGHT_GRAY, alpha=0.3, edgecolor=IBM_GRAY)
    ax.add_patch(activity_rect)
    ax.text(4, 3.5, 'TEAM ACTIVITY', fontsize=style['text_size'], fontweight='bold',
            ha='center', va='center')
    
    team_activities = [
        'alice@company.com: terraform apply (2 min ago)',
        'bob@company.com: terraform plan (15 min ago)',
        'charlie@company.com: force-unlock (1 hr ago)'
    ]
    
    for i, activity in enumerate(team_activities):
        ax.text(4, 3.1 - i * 0.3, f'• {activity}', fontsize=style['small_text'],
                ha='center', va='center')
    
    # System health
    health_rect = FancyBboxPatch((8.5, 1), 6, 3, boxstyle="round,pad=0.1",
                                facecolor=IBM_LIGHT_GRAY, alpha=0.3, edgecolor=IBM_GRAY)
    ax.add_patch(health_rect)
    ax.text(11.5, 3.5, 'SYSTEM HEALTH', fontsize=style['text_size'], fontweight='bold',
            ha='center', va='center')
    
    health_metrics = [
        ('Backend Availability', '99.9%', IBM_GREEN),
        ('Lock Service Status', 'Healthy', IBM_GREEN),
        ('Drift Detection', 'Active', IBM_GREEN),
        ('Alert System', 'Operational', IBM_GREEN)
    ]
    
    for i, (metric, status, color) in enumerate(health_metrics):
        metric_y = 3.1 - i * 0.25
        status_indicator = Circle((13.8, metric_y), 0.08, facecolor=color, alpha=0.8)
        ax.add_patch(status_indicator)
        ax.text(9, metric_y, metric, fontsize=style['small_text'],
                ha='left', va='center')
        ax.text(12.5, metric_y, status, fontsize=style['small_text'], fontweight='bold',
                ha='left', va='center', color=color)
    
    add_ibm_branding(ax)
    plt.tight_layout()
    plt.savefig('generated_diagrams/figure_6_2_5_enterprise_monitoring.png', dpi=300, bbox_inches='tight')
    plt.close()

def main():
    """Generate all state locking and drift detection diagrams"""
    print("Generating State Locking and Drift Detection Diagrams...")
    print("=" * 60)
    
    diagrams = [
        ("Figure 6.2.1: State Locking Mechanism", diagram_1_state_locking_mechanism),
        ("Figure 6.2.2: Drift Detection Architecture", diagram_2_drift_detection_architecture),
        ("Figure 6.2.3: Conflict Resolution Workflow", diagram_3_conflict_resolution_workflow),
        ("Figure 6.2.4: Automated Remediation Process", diagram_4_automated_remediation),
        ("Figure 6.2.5: Enterprise Monitoring Dashboard", diagram_5_enterprise_monitoring)
    ]
    
    for name, func in diagrams:
        print(f"Generating {name}...")
        func()
        print(f"✅ {name} completed")
    
    print("=" * 60)
    print("All diagrams generated successfully!")
    print(f"Output directory: generated_diagrams/")
    print(f"Resolution: 300 DPI")
    print(f"Format: PNG")
    
    # List generated files
    import glob
    files = glob.glob('generated_diagrams/*.png')
    print(f"\nGenerated files ({len(files)}):")
    for file in sorted(files):
        print(f"  - {file}")

if __name__ == "__main__":
    main()
