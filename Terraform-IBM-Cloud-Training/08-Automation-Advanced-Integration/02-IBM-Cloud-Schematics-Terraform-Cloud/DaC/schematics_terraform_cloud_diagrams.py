#!/usr/bin/env python3
"""
IBM Cloud Schematics & Terraform Cloud Integration - Diagram Generation Script

This script generates professional diagrams for Topic 8.2 covering:
1. Schematics Enterprise Architecture
2. Terraform Cloud Integration Patterns  
3. Multi-Workspace Orchestration
4. Team Collaboration Workflows
5. Cost Optimization Dashboard

Author: IBM Cloud Terraform Training Team
Version: 1.0.0
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, ConnectionPatch
import numpy as np
import os
from datetime import datetime

# IBM Cloud color palette
IBM_COLORS = {
    'blue': '#0f62fe',
    'dark_blue': '#002d9c',
    'light_blue': '#4589ff',
    'gray': '#525252',
    'light_gray': '#f4f4f4',
    'white': '#ffffff',
    'green': '#24a148',
    'orange': '#ff832b',
    'red': '#da1e28',
    'purple': '#8a3ffc'
}

def setup_figure(title, figsize=(16, 12)):
    """Setup figure with IBM Cloud styling"""
    fig, ax = plt.subplots(figsize=figsize)
    fig.patch.set_facecolor(IBM_COLORS['white'])
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')
    
    # Add title
    ax.text(50, 95, title, fontsize=20, fontweight='bold', 
            ha='center', va='center', color=IBM_COLORS['dark_blue'])
    
    return fig, ax

def add_rounded_box(ax, x, y, width, height, text, color, text_color='white'):
    """Add a rounded rectangle with text"""
    box = FancyBboxPatch((x, y), width, height,
                         boxstyle="round,pad=0.5",
                         facecolor=color,
                         edgecolor=IBM_COLORS['gray'],
                         linewidth=1.5)
    ax.add_patch(box)
    
    ax.text(x + width/2, y + height/2, text,
            ha='center', va='center', fontsize=10, fontweight='bold',
            color=text_color, wrap=True)

def add_arrow(ax, start, end, color=IBM_COLORS['gray'], style='->'):
    """Add arrow between two points"""
    arrow = ConnectionPatch(start, end, "data", "data",
                          arrowstyle=style, shrinkA=5, shrinkB=5,
                          mutation_scale=20, fc=color, ec=color, linewidth=2)
    ax.add_patch(arrow)

def generate_diagram_1_schematics_architecture():
    """Generate Diagram 1: Schematics Enterprise Architecture"""
    fig, ax = setup_figure("IBM Cloud Schematics Enterprise Architecture")
    
    # IBM Cloud Platform Layer
    add_rounded_box(ax, 5, 80, 90, 12, "IBM Cloud Platform", IBM_COLORS['dark_blue'])
    
    # Schematics Service Components
    add_rounded_box(ax, 10, 65, 18, 10, "Workspace\nEngine", IBM_COLORS['blue'])
    add_rounded_box(ax, 32, 65, 18, 10, "State\nManagement", IBM_COLORS['blue'])
    add_rounded_box(ax, 54, 65, 18, 10, "Variable\nManagement", IBM_COLORS['blue'])
    add_rounded_box(ax, 76, 65, 18, 10, "Execution\nEngine", IBM_COLORS['blue'])
    
    # Security Layer
    add_rounded_box(ax, 5, 50, 25, 8, "IAM Integration", IBM_COLORS['green'])
    add_rounded_box(ax, 35, 50, 25, 8, "Encryption at Rest", IBM_COLORS['green'])
    add_rounded_box(ax, 70, 50, 25, 8, "Network Isolation", IBM_COLORS['green'])
    
    # Workspace Hierarchy
    add_rounded_box(ax, 10, 30, 35, 15, "Production\nWorkspaces\n• Core Infrastructure\n• Application Tier\n• Security Layer", IBM_COLORS['orange'])
    add_rounded_box(ax, 55, 30, 35, 15, "Development\nWorkspaces\n• Feature Development\n• Testing\n• Experimentation", IBM_COLORS['light_blue'])
    
    # External Integrations
    add_rounded_box(ax, 10, 10, 20, 8, "Git Repositories", IBM_COLORS['purple'])
    add_rounded_box(ax, 40, 10, 20, 8, "CI/CD Pipelines", IBM_COLORS['purple'])
    add_rounded_box(ax, 70, 10, 20, 8, "Monitoring", IBM_COLORS['purple'])
    
    # Add connections
    add_arrow(ax, (19, 65), (19, 58))
    add_arrow(ax, (41, 65), (41, 58))
    add_arrow(ax, (63, 65), (63, 58))
    add_arrow(ax, (85, 65), (85, 58))
    
    add_arrow(ax, (27.5, 45), (27.5, 30))
    add_arrow(ax, (72.5, 45), (72.5, 30))
    
    plt.tight_layout()
    plt.savefig('Terraform-IBM-Cloud-Training/08-Automation-Advanced-Integration/02-IBM-Cloud-Schematics-Terraform-Cloud/DaC/diagrams/Figure_8.2.1_Schematics_Enterprise_Architecture.png', 
                dpi=300, bbox_inches='tight', facecolor='white')
    plt.close()

def generate_diagram_2_terraform_cloud_integration():
    """Generate Diagram 2: Terraform Cloud Integration Patterns"""
    fig, ax = setup_figure("Terraform Cloud Integration Patterns")
    
    # Terraform Cloud Platform
    add_rounded_box(ax, 5, 80, 40, 12, "Terraform Cloud Platform\n• Organization Management\n• Advanced Features", IBM_COLORS['purple'])
    
    # IBM Cloud Schematics
    add_rounded_box(ax, 55, 80, 40, 12, "IBM Cloud Schematics\n• Managed Terraform\n• IBM Cloud Native", IBM_COLORS['blue'])
    
    # Integration Layer
    add_rounded_box(ax, 25, 60, 50, 8, "Hybrid Integration Layer", IBM_COLORS['orange'])
    
    # Shared Components
    add_rounded_box(ax, 10, 40, 20, 12, "Shared\nVariables\n& Secrets", IBM_COLORS['green'])
    add_rounded_box(ax, 40, 40, 20, 12, "Cross-Platform\nWorkflows", IBM_COLORS['green'])
    add_rounded_box(ax, 70, 40, 20, 12, "Unified\nMonitoring", IBM_COLORS['green'])
    
    # Workspace Types
    add_rounded_box(ax, 5, 20, 25, 12, "TF Cloud Workspaces\n• Multi-Cloud\n• Advanced Governance\n• Policy as Code", IBM_COLORS['light_blue'])
    add_rounded_box(ax, 37.5, 20, 25, 12, "Hybrid Workspaces\n• Cross-Platform\n• Shared State\n• Unified Deployment", IBM_COLORS['orange'])
    add_rounded_box(ax, 70, 20, 25, 12, "Schematics Workspaces\n• IBM Cloud Native\n• Enterprise Security\n• Managed Service", IBM_COLORS['blue'])
    
    # Benefits
    add_rounded_box(ax, 20, 5, 60, 8, "Benefits: Unified Management • Cost Optimization • Enhanced Security", IBM_COLORS['gray'], IBM_COLORS['white'])
    
    # Add connections
    add_arrow(ax, (25, 80), (35, 68))
    add_arrow(ax, (75, 80), (65, 68))
    
    add_arrow(ax, (35, 60), (20, 52))
    add_arrow(ax, (50, 60), (50, 52))
    add_arrow(ax, (65, 60), (80, 52))
    
    add_arrow(ax, (20, 40), (17.5, 32))
    add_arrow(ax, (50, 40), (50, 32))
    add_arrow(ax, (80, 40), (82.5, 32))
    
    plt.tight_layout()
    plt.savefig('Terraform-IBM-Cloud-Training/08-Automation-Advanced-Integration/02-IBM-Cloud-Schematics-Terraform-Cloud/DaC/diagrams/Figure_8.2.2_Terraform_Cloud_Integration.png', 
                dpi=300, bbox_inches='tight', facecolor='white')
    plt.close()

def generate_diagram_3_multi_workspace_orchestration():
    """Generate Diagram 3: Multi-Workspace Orchestration"""
    fig, ax = setup_figure("Multi-Workspace Orchestration")
    
    # Orchestration Controller
    add_rounded_box(ax, 35, 85, 30, 10, "Orchestration Controller", IBM_COLORS['dark_blue'])
    
    # Network Layer (Foundation)
    add_rounded_box(ax, 10, 65, 80, 8, "Network Infrastructure Workspace (Foundation Layer)", IBM_COLORS['blue'])
    
    # Application Layer
    add_rounded_box(ax, 5, 50, 25, 10, "Web Tier\nWorkspace", IBM_COLORS['orange'])
    add_rounded_box(ax, 37.5, 50, 25, 10, "Application Tier\nWorkspace", IBM_COLORS['orange'])
    add_rounded_box(ax, 70, 50, 25, 10, "Data Tier\nWorkspace", IBM_COLORS['orange'])
    
    # Security and Monitoring
    add_rounded_box(ax, 10, 30, 35, 10, "Security Workspace\n• IAM Policies\n• Key Management", IBM_COLORS['green'])
    add_rounded_box(ax, 55, 30, 35, 10, "Monitoring Workspace\n• Logging\n• Alerting", IBM_COLORS['green'])
    
    # Dependency Flow
    add_rounded_box(ax, 20, 10, 60, 8, "Dependency Management: Network → Application → Security/Monitoring", IBM_COLORS['gray'], IBM_COLORS['white'])
    
    # Add dependency arrows
    add_arrow(ax, (50, 85), (50, 73))  # Controller to Network
    
    add_arrow(ax, (30, 65), (17.5, 60))  # Network to Web
    add_arrow(ax, (50, 65), (50, 60))    # Network to App
    add_arrow(ax, (70, 65), (82.5, 60))  # Network to Data
    
    add_arrow(ax, (17.5, 50), (27.5, 40))  # Web to Security
    add_arrow(ax, (50, 50), (72.5, 40))    # App to Monitoring
    add_arrow(ax, (82.5, 50), (72.5, 40))  # Data to Monitoring
    
    # Add execution order numbers
    ax.text(52, 79, "1", fontsize=14, fontweight='bold', ha='center', va='center', 
            bbox=dict(boxstyle="circle", facecolor=IBM_COLORS['white'], edgecolor=IBM_COLORS['dark_blue']))
    ax.text(52, 69, "2", fontsize=14, fontweight='bold', ha='center', va='center',
            bbox=dict(boxstyle="circle", facecolor=IBM_COLORS['white'], edgecolor=IBM_COLORS['blue']))
    ax.text(17.5, 55, "3a", fontsize=12, fontweight='bold', ha='center', va='center',
            bbox=dict(boxstyle="circle", facecolor=IBM_COLORS['white'], edgecolor=IBM_COLORS['orange']))
    ax.text(50, 55, "3b", fontsize=12, fontweight='bold', ha='center', va='center',
            bbox=dict(boxstyle="circle", facecolor=IBM_COLORS['white'], edgecolor=IBM_COLORS['orange']))
    ax.text(82.5, 55, "3c", fontsize=12, fontweight='bold', ha='center', va='center',
            bbox=dict(boxstyle="circle", facecolor=IBM_COLORS['white'], edgecolor=IBM_COLORS['orange']))
    ax.text(27.5, 35, "4a", fontsize=12, fontweight='bold', ha='center', va='center',
            bbox=dict(boxstyle="circle", facecolor=IBM_COLORS['white'], edgecolor=IBM_COLORS['green']))
    ax.text(72.5, 35, "4b", fontsize=12, fontweight='bold', ha='center', va='center',
            bbox=dict(boxstyle="circle", facecolor=IBM_COLORS['white'], edgecolor=IBM_COLORS['green']))
    
    plt.tight_layout()
    plt.savefig('Terraform-IBM-Cloud-Training/08-Automation-Advanced-Integration/02-IBM-Cloud-Schematics-Terraform-Cloud/DaC/diagrams/Figure_8.2.3_Multi_Workspace_Orchestration.png', 
                dpi=300, bbox_inches='tight', facecolor='white')
    plt.close()

def generate_diagram_4_team_collaboration():
    """Generate Diagram 4: Team Collaboration Workflows"""
    fig, ax = setup_figure("Team Collaboration Workflows")
    
    # Teams
    add_rounded_box(ax, 5, 80, 20, 12, "Development\nTeam\n• Feature Dev\n• Testing", IBM_COLORS['light_blue'])
    add_rounded_box(ax, 40, 80, 20, 12, "Infrastructure\nTeam\n• Core Services\n• Security", IBM_COLORS['blue'])
    add_rounded_box(ax, 75, 80, 20, 12, "Operations\nTeam\n• Monitoring\n• Maintenance", IBM_COLORS['green'])
    
    # Collaboration Layer
    add_rounded_box(ax, 10, 60, 80, 8, "Collaboration Platform (IBM Cloud Schematics + Terraform Cloud)", IBM_COLORS['orange'])
    
    # Workflow Components
    add_rounded_box(ax, 5, 40, 25, 12, "Role-Based\nAccess Control\n• Viewer\n• Operator\n• Manager", IBM_COLORS['purple'])
    add_rounded_box(ax, 37.5, 40, 25, 12, "Approval\nWorkflows\n• Multi-Stage\n• Policy Validation\n• Audit Trails", IBM_COLORS['purple'])
    add_rounded_box(ax, 70, 40, 25, 12, "Shared\nResources\n• Variables\n• State\n• Documentation", IBM_COLORS['purple'])
    
    # Governance Layer
    add_rounded_box(ax, 15, 20, 70, 8, "Governance Framework: Policy as Code • Compliance Automation • Audit Logging", IBM_COLORS['gray'], IBM_COLORS['white'])
    
    # Benefits
    add_rounded_box(ax, 10, 5, 80, 8, "Outcomes: 85% Faster Collaboration • 95% Reduced Conflicts • 100% Audit Compliance", IBM_COLORS['green'], IBM_COLORS['white'])
    
    # Add connections
    add_arrow(ax, (15, 80), (25, 68))
    add_arrow(ax, (50, 80), (50, 68))
    add_arrow(ax, (85, 80), (75, 68))
    
    add_arrow(ax, (30, 60), (17.5, 52))
    add_arrow(ax, (50, 60), (50, 52))
    add_arrow(ax, (70, 60), (82.5, 52))
    
    add_arrow(ax, (50, 40), (50, 28))
    
    plt.tight_layout()
    plt.savefig('Terraform-IBM-Cloud-Training/08-Automation-Advanced-Integration/02-IBM-Cloud-Schematics-Terraform-Cloud/DaC/diagrams/Figure_8.2.4_Team_Collaboration_Workflows.png', 
                dpi=300, bbox_inches='tight', facecolor='white')
    plt.close()

def generate_diagram_5_cost_optimization():
    """Generate Diagram 5: Cost Optimization Dashboard"""
    fig, ax = setup_figure("Cost Optimization Dashboard")
    
    # Dashboard Header
    add_rounded_box(ax, 10, 85, 80, 8, "IBM Cloud Schematics Cost Optimization Dashboard", IBM_COLORS['dark_blue'])
    
    # Cost Monitoring Widgets
    add_rounded_box(ax, 5, 70, 25, 10, "Real-Time\nCost Tracking\n$1,247/month\n↓ 23% vs last month", IBM_COLORS['green'])
    add_rounded_box(ax, 37.5, 70, 25, 10, "Budget Alerts\n$1,500 limit\n83% utilized\n⚠️ Threshold reached", IBM_COLORS['orange'])
    add_rounded_box(ax, 70, 70, 25, 10, "Resource\nUtilization\n67% average\n↑ 12% efficiency", IBM_COLORS['blue'])
    
    # Optimization Recommendations
    add_rounded_box(ax, 5, 50, 40, 15, "Optimization Recommendations\n• Resize 3 over-provisioned VMs\n• Schedule dev environment shutdown\n• Implement auto-scaling policies\nPotential Savings: $312/month", IBM_COLORS['purple'])
    
    add_rounded_box(ax, 55, 50, 40, 15, "Lifecycle Management\n• Auto-cleanup unused resources\n• Scheduled environment management\n• Policy-driven cost controls\nAutomated Savings: $189/month", IBM_COLORS['light_blue'])
    
    # Cost Breakdown Chart Area
    add_rounded_box(ax, 10, 25, 35, 20, "Cost Breakdown by Service\n\nCompute: 45% ($561)\nStorage: 25% ($312)\nNetwork: 20% ($249)\nSecurity: 10% ($125)", IBM_COLORS['light_gray'], IBM_COLORS['gray'])
    
    add_rounded_box(ax, 55, 25, 35, 20, "Trend Analysis\n\n📈 3-month cost trend\n📊 Resource usage patterns\n🎯 Optimization opportunities\n💡 Predictive insights", IBM_COLORS['light_gray'], IBM_COLORS['gray'])
    
    # Action Items
    add_rounded_box(ax, 15, 5, 70, 8, "Action Items: Review VM sizing • Implement tagging strategy • Enable auto-shutdown", IBM_COLORS['red'], IBM_COLORS['white'])
    
    # Add metric indicators
    ax.text(17.5, 75, "✓", fontsize=20, fontweight='bold', ha='center', va='center', color=IBM_COLORS['white'])
    ax.text(50, 75, "⚠", fontsize=20, fontweight='bold', ha='center', va='center', color=IBM_COLORS['white'])
    ax.text(82.5, 75, "↗", fontsize=20, fontweight='bold', ha='center', va='center', color=IBM_COLORS['white'])
    
    plt.tight_layout()
    plt.savefig('Terraform-IBM-Cloud-Training/08-Automation-Advanced-Integration/02-IBM-Cloud-Schematics-Terraform-Cloud/DaC/diagrams/Figure_8.2.5_Cost_Optimization_Dashboard.png', 
                dpi=300, bbox_inches='tight', facecolor='white')
    plt.close()

def main():
    """Generate all diagrams for Topic 8.2"""
    print("Generating IBM Cloud Schematics & Terraform Cloud Integration Diagrams...")
    print(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Create output directory if it doesn't exist
    os.makedirs('Terraform-IBM-Cloud-Training/08-Automation-Advanced-Integration/02-IBM-Cloud-Schematics-Terraform-Cloud/DaC/diagrams', exist_ok=True)
    
    # Generate all diagrams
    diagrams = [
        ("Schematics Enterprise Architecture", generate_diagram_1_schematics_architecture),
        ("Terraform Cloud Integration Patterns", generate_diagram_2_terraform_cloud_integration),
        ("Multi-Workspace Orchestration", generate_diagram_3_multi_workspace_orchestration),
        ("Team Collaboration Workflows", generate_diagram_4_team_collaboration),
        ("Cost Optimization Dashboard", generate_diagram_5_cost_optimization)
    ]
    
    for i, (name, func) in enumerate(diagrams, 1):
        print(f"Generating Figure 8.2.{i}: {name}...")
        func()
        print(f"✓ Figure 8.2.{i} completed")
    
    print("\n🎉 All diagrams generated successfully!")
    print("📁 Output directory: Terraform-IBM-Cloud-Training/08-Automation-Advanced-Integration/02-IBM-Cloud-Schematics-Terraform-Cloud/DaC/diagrams/")
    print("📊 Resolution: 300 DPI")
    print("🎨 Style: IBM Cloud Enterprise Theme")

if __name__ == "__main__":
    main()
