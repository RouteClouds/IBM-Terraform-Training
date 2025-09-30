#!/usr/bin/env python3
"""
CI/CD Pipeline Integration - Diagram as Code Implementation
Topic 8.1: Advanced CI/CD Pipeline Integration for IBM Cloud Terraform Training

This script generates 5 professional diagrams for CI/CD pipeline integration:
1. Enterprise CI/CD Architecture Ecosystem
2. Multi-Platform Automation Comparison Matrix
3. Security Scanning and Policy Validation Workflow
4. Advanced Deployment Strategy Patterns
5. Pipeline Performance Optimization and Metrics

Author: IBM Cloud Terraform Training Team
Version: 1.0.0
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, ConnectionPatch, Rectangle
import numpy as np
import seaborn as sns
from datetime import datetime
import os

# IBM Cloud Brand Colors
COLORS = {
    'primary': '#0f62fe',      # IBM Blue
    'secondary': '#393939',    # IBM Gray
    'accent': '#ff832b',       # IBM Orange
    'success': '#24a148',      # IBM Green
    'warning': '#f1c21b',      # IBM Yellow
    'error': '#da1e28',        # IBM Red
    'background': '#f4f4f4',   # Light Gray
    'text': '#161616',         # Dark Gray
    'white': '#ffffff'
}

# Set style and DPI for high-quality output
plt.style.use('default')
plt.rcParams['figure.dpi'] = 300
plt.rcParams['savefig.dpi'] = 300
plt.rcParams['font.family'] = 'sans-serif'
plt.rcParams['font.sans-serif'] = ['IBM Plex Sans', 'Arial', 'sans-serif']

def create_enterprise_cicd_architecture():
    """
    Figure 8.1.1: Enterprise CI/CD Architecture Ecosystem
    Comprehensive visualization of enterprise CI/CD architecture with security integration
    """
    fig, ax = plt.subplots(figsize=(16, 12))
    ax.set_xlim(0, 16)
    ax.set_ylim(0, 12)
    ax.axis('off')
    
    # Title
    ax.text(8, 11.5, 'Enterprise CI/CD Architecture Ecosystem', 
            fontsize=20, fontweight='bold', ha='center', color=COLORS['text'])
    ax.text(8, 11, 'Comprehensive Pipeline Integration with Security and Compliance', 
            fontsize=14, ha='center', color=COLORS['secondary'])
    
    # Source Control Layer
    source_box = FancyBboxPatch((0.5, 9), 3, 1.5, boxstyle="round,pad=0.1", 
                               facecolor=COLORS['primary'], edgecolor=COLORS['text'], linewidth=2)
    ax.add_patch(source_box)
    ax.text(2, 9.75, 'Source Control', fontsize=12, fontweight='bold', ha='center', color='white')
    ax.text(2, 9.25, 'Git • GitHub • GitLab', fontsize=10, ha='center', color='white')
    
    # CI/CD Platforms Layer
    platforms = [
        {'name': 'GitLab CI', 'pos': (4.5, 9), 'color': COLORS['accent']},
        {'name': 'GitHub Actions', 'pos': (7.5, 9), 'color': COLORS['success']},
        {'name': 'Jenkins', 'pos': (10.5, 9), 'color': COLORS['warning']}
    ]
    
    for platform in platforms:
        platform_box = FancyBboxPatch(platform['pos'], 2.5, 1.5, boxstyle="round,pad=0.1",
                                     facecolor=platform['color'], edgecolor=COLORS['text'], linewidth=2)
        ax.add_patch(platform_box)
        ax.text(platform['pos'][0] + 1.25, platform['pos'][1] + 0.75, platform['name'], 
                fontsize=11, fontweight='bold', ha='center', color='white')
    
    # Pipeline Stages
    stages = [
        {'name': 'Validate', 'pos': (1, 7), 'icon': '✓'},
        {'name': 'Security', 'pos': (3.5, 7), 'icon': '🔒'},
        {'name': 'Cost', 'pos': (6, 7), 'icon': '💰'},
        {'name': 'Plan', 'pos': (8.5, 7), 'icon': '📋'},
        {'name': 'Deploy', 'pos': (11, 7), 'icon': '🚀'},
        {'name': 'Monitor', 'pos': (13.5, 7), 'icon': '📊'}
    ]
    
    for i, stage in enumerate(stages):
        stage_box = FancyBboxPatch(stage['pos'], 2, 1, boxstyle="round,pad=0.1",
                                  facecolor=COLORS['background'], edgecolor=COLORS['primary'], linewidth=2)
        ax.add_patch(stage_box)
        ax.text(stage['pos'][0] + 1, stage['pos'][1] + 0.7, stage['icon'], 
                fontsize=16, ha='center')
        ax.text(stage['pos'][0] + 1, stage['pos'][1] + 0.3, stage['name'], 
                fontsize=10, fontweight='bold', ha='center', color=COLORS['text'])
        
        # Connect stages with arrows
        if i < len(stages) - 1:
            arrow = ConnectionPatch((stage['pos'][0] + 2, stage['pos'][1] + 0.5),
                                  (stages[i+1]['pos'][0], stages[i+1]['pos'][1] + 0.5),
                                  "data", "data", arrowstyle="->", shrinkA=5, shrinkB=5,
                                  mutation_scale=20, fc=COLORS['primary'], ec=COLORS['primary'])
            ax.add_patch(arrow)
    
    # Security Tools Layer
    security_tools = [
        {'name': 'TFSec', 'pos': (1, 5)},
        {'name': 'Checkov', 'pos': (3.5, 5)},
        {'name': 'Terrascan', 'pos': (6, 5)},
        {'name': 'OPA', 'pos': (8.5, 5)},
        {'name': 'Sentinel', 'pos': (11, 5)},
        {'name': 'SIEM', 'pos': (13.5, 5)}
    ]
    
    for tool in security_tools:
        tool_box = FancyBboxPatch(tool['pos'], 1.8, 0.8, boxstyle="round,pad=0.05",
                                 facecolor=COLORS['error'], edgecolor=COLORS['text'], linewidth=1)
        ax.add_patch(tool_box)
        ax.text(tool['pos'][0] + 0.9, tool['pos'][1] + 0.4, tool['name'], 
                fontsize=9, fontweight='bold', ha='center', color='white')
    
    # IBM Cloud Services Layer
    ibm_services = [
        {'name': 'Schematics', 'pos': (2, 3)},
        {'name': 'Code Engine', 'pos': (5, 3)},
        {'name': 'DevOps Toolchain', 'pos': (8, 3)},
        {'name': 'Activity Tracker', 'pos': (11, 3)}
    ]
    
    for service in ibm_services:
        service_box = FancyBboxPatch(service['pos'], 2.5, 1, boxstyle="round,pad=0.1",
                                    facecolor=COLORS['primary'], edgecolor=COLORS['text'], linewidth=2)
        ax.add_patch(service_box)
        ax.text(service['pos'][0] + 1.25, service['pos'][1] + 0.5, service['name'], 
                fontsize=10, fontweight='bold', ha='center', color='white')
    
    # Deployment Environments
    environments = [
        {'name': 'Development', 'pos': (1, 1), 'color': COLORS['success']},
        {'name': 'Staging', 'pos': (5.5, 1), 'color': COLORS['warning']},
        {'name': 'Production', 'pos': (10, 1), 'color': COLORS['error']}
    ]
    
    for env in environments:
        env_box = FancyBboxPatch(env['pos'], 3, 1, boxstyle="round,pad=0.1",
                                facecolor=env['color'], edgecolor=COLORS['text'], linewidth=2)
        ax.add_patch(env_box)
        ax.text(env['pos'][0] + 1.5, env['pos'][1] + 0.5, env['name'], 
                fontsize=11, fontweight='bold', ha='center', color='white')
    
    # Add flow arrows
    flow_arrows = [
        ((2, 9), (6, 8)),  # Source to Platforms
        ((6, 7), (6, 6)),  # Stages to Security
        ((6, 5), (6, 4)),  # Security to IBM Cloud
        ((6, 3), (6, 2))   # IBM Cloud to Environments
    ]
    
    for start, end in flow_arrows:
        arrow = ConnectionPatch(start, end, "data", "data", arrowstyle="->", 
                              shrinkA=5, shrinkB=5, mutation_scale=20, 
                              fc=COLORS['secondary'], ec=COLORS['secondary'])
        ax.add_patch(arrow)
    
    # Add legend
    legend_elements = [
        {'label': 'Source Control', 'color': COLORS['primary']},
        {'label': 'CI/CD Platforms', 'color': COLORS['accent']},
        {'label': 'Security Tools', 'color': COLORS['error']},
        {'label': 'IBM Cloud Services', 'color': COLORS['primary']},
        {'label': 'Environments', 'color': COLORS['success']}
    ]
    
    for i, element in enumerate(legend_elements):
        legend_box = Rectangle((14, 9.5 - i * 0.5), 0.3, 0.3, 
                              facecolor=element['color'], edgecolor=COLORS['text'])
        ax.add_patch(legend_box)
        ax.text(14.5, 9.65 - i * 0.5, element['label'], fontsize=9, 
                va='center', color=COLORS['text'])
    
    plt.tight_layout()
    plt.savefig('Figure_8.1.1_Enterprise_CICD_Architecture.png', 
                bbox_inches='tight', facecolor='white', edgecolor='none')
    plt.close()

def create_multiplatform_comparison():
    """
    Figure 8.1.2: Multi-Platform Automation Comparison Matrix
    Detailed comparison of GitLab CI, GitHub Actions, and Jenkins capabilities
    """
    fig, ax = plt.subplots(figsize=(14, 10))
    
    # Comparison data
    platforms = ['GitLab CI', 'GitHub Actions', 'Jenkins']
    features = [
        'Setup Complexity',
        'IBM Cloud Integration',
        'Security Scanning',
        'Cost Analysis',
        'Policy Validation',
        'Multi-Environment',
        'Performance',
        'Enterprise Features',
        'Community Support',
        'Maintenance Overhead'
    ]
    
    # Scoring matrix (1-5 scale, 5 being best)
    scores = np.array([
        [4, 5, 3],  # Setup Complexity
        [5, 4, 3],  # IBM Cloud Integration
        [5, 4, 4],  # Security Scanning
        [4, 5, 3],  # Cost Analysis
        [5, 4, 4],  # Policy Validation
        [5, 5, 4],  # Multi-Environment
        [4, 4, 3],  # Performance
        [5, 3, 5],  # Enterprise Features
        [4, 5, 5],  # Community Support
        [4, 5, 2]   # Maintenance Overhead
    ])
    
    # Create heatmap
    im = ax.imshow(scores, cmap='RdYlGn', aspect='auto', vmin=1, vmax=5)
    
    # Set ticks and labels
    ax.set_xticks(np.arange(len(platforms)))
    ax.set_yticks(np.arange(len(features)))
    ax.set_xticklabels(platforms, fontsize=12, fontweight='bold')
    ax.set_yticklabels(features, fontsize=11)
    
    # Add text annotations
    for i in range(len(features)):
        for j in range(len(platforms)):
            text = ax.text(j, i, scores[i, j], ha="center", va="center", 
                          color="black", fontsize=12, fontweight='bold')
    
    # Title and labels
    ax.set_title('Multi-Platform CI/CD Comparison Matrix\nCapability Assessment (1=Poor, 5=Excellent)', 
                fontsize=16, fontweight='bold', pad=20, color=COLORS['text'])
    
    # Add colorbar
    cbar = plt.colorbar(im, ax=ax, shrink=0.8)
    cbar.set_label('Capability Score', rotation=270, labelpad=20, fontsize=12)
    
    # Add platform recommendations
    recommendations = [
        "GitLab CI: Best for enterprise security and IBM Cloud integration",
        "GitHub Actions: Optimal for cloud-native workflows and cost analysis",
        "Jenkins: Ideal for complex enterprise environments with custom requirements"
    ]
    
    for i, rec in enumerate(recommendations):
        ax.text(0.5, -1.5 - i * 0.3, rec, transform=ax.transAxes, 
                fontsize=10, ha='left', color=COLORS['secondary'])
    
    plt.tight_layout()
    plt.savefig('Figure_8.1.2_MultiPlatform_Comparison.png', 
                bbox_inches='tight', facecolor='white', edgecolor='none')
    plt.close()

def create_security_workflow():
    """
    Figure 8.1.3: Security Scanning and Policy Validation Workflow
    Comprehensive security integration workflow with automated remediation
    """
    fig, ax = plt.subplots(figsize=(15, 10))
    ax.set_xlim(0, 15)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Title
    ax.text(7.5, 9.5, 'Security Scanning and Policy Validation Workflow', 
            fontsize=18, fontweight='bold', ha='center', color=COLORS['text'])
    ax.text(7.5, 9, 'Automated Security Integration with Policy Enforcement', 
            fontsize=12, ha='center', color=COLORS['secondary'])
    
    # Code Commit
    commit_box = FancyBboxPatch((1, 7.5), 2, 1, boxstyle="round,pad=0.1",
                               facecolor=COLORS['primary'], edgecolor=COLORS['text'], linewidth=2)
    ax.add_patch(commit_box)
    ax.text(2, 8, 'Code Commit', fontsize=11, fontweight='bold', ha='center', color='white')
    
    # Security Scanning Tools
    security_tools = [
        {'name': 'TFSec\nStatic Analysis', 'pos': (4.5, 8), 'color': COLORS['error']},
        {'name': 'Checkov\nPolicy Check', 'pos': (7, 8), 'color': COLORS['warning']},
        {'name': 'Terrascan\nCompliance', 'pos': (9.5, 8), 'color': COLORS['accent']},
        {'name': 'Custom\nValidation', 'pos': (12, 8), 'color': COLORS['success']}
    ]
    
    for tool in security_tools:
        tool_box = FancyBboxPatch(tool['pos'], 2, 1, boxstyle="round,pad=0.1",
                                 facecolor=tool['color'], edgecolor=COLORS['text'], linewidth=2)
        ax.add_patch(tool_box)
        ax.text(tool['pos'][0] + 1, tool['pos'][1] + 0.5, tool['name'], 
                fontsize=9, fontweight='bold', ha='center', color='white')
    
    # Policy Validation Layer
    policy_box = FancyBboxPatch((4, 6), 7, 1, boxstyle="round,pad=0.1",
                               facecolor=COLORS['primary'], edgecolor=COLORS['text'], linewidth=2)
    ax.add_patch(policy_box)
    ax.text(7.5, 6.5, 'Policy as Code Validation (OPA • Sentinel • Custom)', 
            fontsize=11, fontweight='bold', ha='center', color='white')
    
    # Decision Diamond
    decision_points = [
        {'pos': (2, 4.5), 'label': 'Security\nPassed?', 'color': COLORS['warning']},
        {'pos': (7.5, 4.5), 'label': 'Policy\nCompliant?', 'color': COLORS['accent']},
        {'pos': (12, 4.5), 'label': 'Auto-Fix\nAvailable?', 'color': COLORS['success']}
    ]
    
    for decision in decision_points:
        # Create diamond shape
        diamond = patches.RegularPolygon(decision['pos'], 4, radius=0.8, 
                                       orientation=np.pi/4, facecolor=decision['color'],
                                       edgecolor=COLORS['text'], linewidth=2)
        ax.add_patch(diamond)
        ax.text(decision['pos'][0], decision['pos'][1], decision['label'], 
                fontsize=9, fontweight='bold', ha='center', va='center', color='white')
    
    # Remediation Actions
    remediation_box = FancyBboxPatch((4, 2.5), 7, 1, boxstyle="round,pad=0.1",
                                    facecolor=COLORS['error'], edgecolor=COLORS['text'], linewidth=2)
    ax.add_patch(remediation_box)
    ax.text(7.5, 3, 'Automated Remediation & Notification', 
            fontsize=11, fontweight='bold', ha='center', color='white')
    
    # Approval Process
    approval_box = FancyBboxPatch((4, 1), 7, 1, boxstyle="round,pad=0.1",
                                 facecolor=COLORS['success'], edgecolor=COLORS['text'], linewidth=2)
    ax.add_patch(approval_box)
    ax.text(7.5, 1.5, 'Deployment Approval & Execution', 
            fontsize=11, fontweight='bold', ha='center', color='white')
    
    # Add workflow arrows
    workflow_arrows = [
        ((3, 8), (4.5, 8.5)),  # Commit to TFSec
        ((6.5, 8.5), (7, 8.5)),  # TFSec to Checkov
        ((9, 8.5), (9.5, 8.5)),  # Checkov to Terrascan
        ((11.5, 8.5), (12, 8.5)),  # Terrascan to Custom
        ((7.5, 7.5), (7.5, 7)),  # Tools to Policy
        ((7.5, 6), (7.5, 5.3)),  # Policy to Decision
        ((7.5, 3.8), (7.5, 3.5)),  # Decision to Remediation
        ((7.5, 2.5), (7.5, 2))   # Remediation to Approval
    ]
    
    for start, end in workflow_arrows:
        arrow = ConnectionPatch(start, end, "data", "data", arrowstyle="->", 
                              shrinkA=5, shrinkB=5, mutation_scale=20, 
                              fc=COLORS['secondary'], ec=COLORS['secondary'])
        ax.add_patch(arrow)
    
    # Add metrics
    metrics_text = [
        "Security Metrics:",
        "• 95% vulnerability detection",
        "• 100% policy compliance",
        "• 80% automated remediation",
        "• <5 min scan execution"
    ]
    
    for i, metric in enumerate(metrics_text):
        weight = 'bold' if i == 0 else 'normal'
        ax.text(0.5, 3 - i * 0.3, metric, fontsize=10, fontweight=weight, 
                color=COLORS['text'])
    
    plt.tight_layout()
    plt.savefig('Figure_8.1.3_Security_Workflow.png', 
                bbox_inches='tight', facecolor='white', edgecolor='none')
    plt.close()

def create_deployment_strategies():
    """
    Figure 8.1.4: Advanced Deployment Strategy Patterns
    Visual representation of blue-green, canary, and rolling deployment strategies
    """
    fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(16, 12))
    
    # Blue-Green Deployment
    ax1.set_xlim(0, 10)
    ax1.set_ylim(0, 8)
    ax1.set_title('Blue-Green Deployment Strategy', fontsize=14, fontweight='bold', color=COLORS['text'])
    
    # Blue environment
    blue_box = FancyBboxPatch((1, 5), 3, 2, boxstyle="round,pad=0.1",
                             facecolor=COLORS['primary'], edgecolor=COLORS['text'], linewidth=2)
    ax1.add_patch(blue_box)
    ax1.text(2.5, 6, 'Blue Environment\n(Current Production)', fontsize=10, 
             fontweight='bold', ha='center', color='white')
    
    # Green environment
    green_box = FancyBboxPatch((6, 5), 3, 2, boxstyle="round,pad=0.1",
                              facecolor=COLORS['success'], edgecolor=COLORS['text'], linewidth=2)
    ax1.add_patch(green_box)
    ax1.text(7.5, 6, 'Green Environment\n(New Version)', fontsize=10, 
             fontweight='bold', ha='center', color='white')
    
    # Load balancer
    lb_box = FancyBboxPatch((4, 2), 2, 1, boxstyle="round,pad=0.1",
                           facecolor=COLORS['accent'], edgecolor=COLORS['text'], linewidth=2)
    ax1.add_patch(lb_box)
    ax1.text(5, 2.5, 'Load Balancer', fontsize=10, fontweight='bold', ha='center', color='white')
    
    # Traffic flow arrows
    arrow1 = ConnectionPatch((5, 3), (2.5, 5), "data", "data", arrowstyle="->", 
                           shrinkA=5, shrinkB=5, mutation_scale=20, 
                           fc=COLORS['primary'], ec=COLORS['primary'], linewidth=3)
    ax1.add_patch(arrow1)
    ax1.text(3, 3.8, '100% Traffic', fontsize=9, color=COLORS['primary'], fontweight='bold')
    
    ax1.axis('off')
    
    # Canary Deployment
    ax2.set_xlim(0, 10)
    ax2.set_ylim(0, 8)
    ax2.set_title('Canary Deployment Strategy', fontsize=14, fontweight='bold', color=COLORS['text'])
    
    # Stable version
    stable_box = FancyBboxPatch((1, 5), 2.5, 2, boxstyle="round,pad=0.1",
                               facecolor=COLORS['primary'], edgecolor=COLORS['text'], linewidth=2)
    ax2.add_patch(stable_box)
    ax2.text(2.25, 6, 'Stable Version\n(90% Traffic)', fontsize=9, 
             fontweight='bold', ha='center', color='white')
    
    # Canary version
    canary_box = FancyBboxPatch((6.5, 5), 2.5, 2, boxstyle="round,pad=0.1",
                               facecolor=COLORS['warning'], edgecolor=COLORS['text'], linewidth=2)
    ax2.add_patch(canary_box)
    ax2.text(7.75, 6, 'Canary Version\n(10% Traffic)', fontsize=9, 
             fontweight='bold', ha='center', color='white')
    
    # Traffic distribution
    lb_box2 = FancyBboxPatch((4, 2), 2, 1, boxstyle="round,pad=0.1",
                            facecolor=COLORS['accent'], edgecolor=COLORS['text'], linewidth=2)
    ax2.add_patch(lb_box2)
    ax2.text(5, 2.5, 'Smart Router', fontsize=10, fontweight='bold', ha='center', color='white')
    
    # Traffic arrows with different weights
    arrow2 = ConnectionPatch((4.5, 3), (2.25, 5), "data", "data", arrowstyle="->", 
                           shrinkA=5, shrinkB=5, mutation_scale=20, 
                           fc=COLORS['primary'], ec=COLORS['primary'], linewidth=5)
    ax2.add_patch(arrow2)
    
    arrow3 = ConnectionPatch((5.5, 3), (7.75, 5), "data", "data", arrowstyle="->", 
                           shrinkA=5, shrinkB=5, mutation_scale=20, 
                           fc=COLORS['warning'], ec=COLORS['warning'], linewidth=2)
    ax2.add_patch(arrow3)
    
    ax2.axis('off')
    
    # Rolling Deployment
    ax3.set_xlim(0, 12)
    ax3.set_ylim(0, 8)
    ax3.set_title('Rolling Deployment Strategy', fontsize=14, fontweight='bold', color=COLORS['text'])
    
    # Instance progression
    instances = [
        {'pos': (1, 5), 'version': 'v1', 'color': COLORS['primary']},
        {'pos': (3, 5), 'version': 'v2', 'color': COLORS['success']},
        {'pos': (5, 5), 'version': 'v2', 'color': COLORS['success']},
        {'pos': (7, 5), 'version': 'v1', 'color': COLORS['primary']},
        {'pos': (9, 5), 'version': 'v1', 'color': COLORS['primary']}
    ]
    
    for i, instance in enumerate(instances):
        inst_box = FancyBboxPatch(instance['pos'], 1.5, 1.5, boxstyle="round,pad=0.1",
                                 facecolor=instance['color'], edgecolor=COLORS['text'], linewidth=2)
        ax3.add_patch(inst_box)
        ax3.text(instance['pos'][0] + 0.75, instance['pos'][1] + 0.75, 
                f"Instance {i+1}\n{instance['version']}", fontsize=9, 
                fontweight='bold', ha='center', color='white')
    
    # Progress indicator
    ax3.text(6, 3, 'Rolling Update in Progress: 40% Complete', 
             fontsize=12, fontweight='bold', ha='center', color=COLORS['text'])
    
    ax3.axis('off')
    
    # Deployment Comparison Table
    ax4.axis('off')
    ax4.set_title('Deployment Strategy Comparison', fontsize=14, fontweight='bold', color=COLORS['text'])
    
    comparison_data = [
        ['Strategy', 'Downtime', 'Rollback Speed', 'Resource Usage', 'Risk Level'],
        ['Blue-Green', 'Zero', 'Instant', 'High (2x)', 'Low'],
        ['Canary', 'Zero', 'Fast', 'Medium', 'Very Low'],
        ['Rolling', 'Zero', 'Medium', 'Low', 'Medium']
    ]
    
    # Create table
    table = ax4.table(cellText=comparison_data[1:], colLabels=comparison_data[0],
                     cellLoc='center', loc='center', bbox=[0, 0.3, 1, 0.6])
    table.auto_set_font_size(False)
    table.set_fontsize(10)
    table.scale(1, 2)
    
    # Style header
    for i in range(len(comparison_data[0])):
        table[(0, i)].set_facecolor(COLORS['primary'])
        table[(0, i)].set_text_props(weight='bold', color='white')
    
    # Style data rows
    colors = [COLORS['background'], COLORS['white']]
    for i in range(1, len(comparison_data)):
        for j in range(len(comparison_data[0])):
            table[(i, j)].set_facecolor(colors[i % 2])
    
    plt.tight_layout()
    plt.savefig('Figure_8.1.4_Deployment_Strategies.png', 
                bbox_inches='tight', facecolor='white', edgecolor='none')
    plt.close()

def create_performance_metrics():
    """
    Figure 8.1.5: Pipeline Performance Optimization and Metrics
    Performance metrics dashboard with optimization strategies
    """
    fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(16, 12))
    
    # Pipeline Execution Time Trends
    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun']
    before_optimization = [25, 23, 26, 24, 27, 25]
    after_optimization = [12, 10, 9, 8, 7, 6]
    
    ax1.plot(months, before_optimization, marker='o', linewidth=3, 
             color=COLORS['error'], label='Before Optimization')
    ax1.plot(months, after_optimization, marker='s', linewidth=3, 
             color=COLORS['success'], label='After Optimization')
    ax1.set_title('Pipeline Execution Time Improvement', fontsize=12, fontweight='bold')
    ax1.set_ylabel('Execution Time (minutes)')
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    
    # Success Rate Metrics
    platforms = ['GitLab CI', 'GitHub Actions', 'Jenkins']
    success_rates = [96, 94, 89]
    colors = [COLORS['primary'], COLORS['success'], COLORS['warning']]
    
    bars = ax2.bar(platforms, success_rates, color=colors, alpha=0.8)
    ax2.set_title('Pipeline Success Rates by Platform', fontsize=12, fontweight='bold')
    ax2.set_ylabel('Success Rate (%)')
    ax2.set_ylim(80, 100)
    
    # Add value labels on bars
    for bar, rate in zip(bars, success_rates):
        height = bar.get_height()
        ax2.text(bar.get_x() + bar.get_width()/2., height + 0.5,
                f'{rate}%', ha='center', va='bottom', fontweight='bold')
    
    ax2.grid(True, alpha=0.3, axis='y')
    
    # Cost Optimization Impact
    categories = ['Infrastructure', 'Labor', 'Tools', 'Maintenance']
    before_costs = [100, 100, 100, 100]
    after_costs = [60, 25, 80, 40]
    
    x = np.arange(len(categories))
    width = 0.35
    
    bars1 = ax3.bar(x - width/2, before_costs, width, label='Before', 
                    color=COLORS['error'], alpha=0.7)
    bars2 = ax3.bar(x + width/2, after_costs, width, label='After', 
                    color=COLORS['success'], alpha=0.7)
    
    ax3.set_title('Cost Optimization Impact', fontsize=12, fontweight='bold')
    ax3.set_ylabel('Relative Cost (%)')
    ax3.set_xticks(x)
    ax3.set_xticklabels(categories)
    ax3.legend()
    ax3.grid(True, alpha=0.3, axis='y')
    
    # Performance Optimization Strategies
    ax4.axis('off')
    ax4.set_title('Performance Optimization Strategies', fontsize=12, fontweight='bold')
    
    strategies = [
        "🚀 Parallel Execution: 60% time reduction",
        "💾 Intelligent Caching: 40% faster builds",
        "🔧 Resource Right-sizing: 30% cost savings",
        "📊 Pipeline Monitoring: 95% issue prediction",
        "🔄 Automated Optimization: 50% less manual tuning",
        "⚡ Hot Standby Agents: 80% faster startup"
    ]
    
    for i, strategy in enumerate(strategies):
        ax4.text(0.05, 0.9 - i * 0.12, strategy, fontsize=11, 
                transform=ax4.transAxes, color=COLORS['text'])
    
    # Add ROI summary box
    roi_box = FancyBboxPatch((0.05, 0.05), 0.9, 0.25, boxstyle="round,pad=0.02",
                            facecolor=COLORS['primary'], alpha=0.1, 
                            edgecolor=COLORS['primary'], linewidth=2,
                            transform=ax4.transAxes)
    ax4.add_patch(roi_box)
    
    roi_text = "ROI Summary: 900% annual return\n$1.05M savings from $105K investment\n1.2 month payback period"
    ax4.text(0.5, 0.175, roi_text, fontsize=11, fontweight='bold',
             ha='center', va='center', transform=ax4.transAxes, color=COLORS['primary'])
    
    plt.tight_layout()
    plt.savefig('Figure_8.1.5_Performance_Metrics.png', 
                bbox_inches='tight', facecolor='white', edgecolor='none')
    plt.close()

def main():
    """
    Main function to generate all CI/CD pipeline integration diagrams
    """
    print("🎨 Generating CI/CD Pipeline Integration Diagrams...")
    print("=" * 60)
    
    # Create output directory if it doesn't exist
    os.makedirs('diagrams', exist_ok=True)
    os.chdir('diagrams')
    
    try:
        print("📊 Creating Figure 8.1.1: Enterprise CI/CD Architecture...")
        create_enterprise_cicd_architecture()
        print("✅ Figure 8.1.1 completed successfully")
        
        print("📊 Creating Figure 8.1.2: Multi-Platform Comparison...")
        create_multiplatform_comparison()
        print("✅ Figure 8.1.2 completed successfully")
        
        print("📊 Creating Figure 8.1.3: Security Workflow...")
        create_security_workflow()
        print("✅ Figure 8.1.3 completed successfully")
        
        print("📊 Creating Figure 8.1.4: Deployment Strategies...")
        create_deployment_strategies()
        print("✅ Figure 8.1.4 completed successfully")
        
        print("📊 Creating Figure 8.1.5: Performance Metrics...")
        create_performance_metrics()
        print("✅ Figure 8.1.5 completed successfully")
        
        print("\n🎉 All diagrams generated successfully!")
        print("📁 Diagrams saved in: ./diagrams/")
        print("🔍 Resolution: 300 DPI (print-ready quality)")
        print("🎨 Style: IBM Cloud branding compliant")
        
    except Exception as e:
        print(f"❌ Error generating diagrams: {str(e)}")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())
