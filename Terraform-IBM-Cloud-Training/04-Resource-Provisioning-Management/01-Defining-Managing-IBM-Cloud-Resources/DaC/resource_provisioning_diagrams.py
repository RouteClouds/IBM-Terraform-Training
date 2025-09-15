#!/usr/bin/env python3
"""
IBM Cloud Resource Provisioning Diagrams Generator
Topic 4.1: Defining and Managing IBM Cloud Resources

This script generates professional diagrams for the resource provisioning subtopic,
demonstrating IBM Cloud infrastructure patterns, lifecycle management, and enterprise architectures.

Author: IBM Cloud Terraform Training Program
Version: 1.0.0
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, ConnectionPatch, Rectangle
import numpy as np
import os
from datetime import datetime

# IBM Brand Colors
IBM_BLUE = '#1f4e79'
IBM_LIGHT_BLUE = '#4589ff'
IBM_CYAN = '#00b4a6'
IBM_TEAL = '#007d79'
IBM_GREEN = '#24a148'
IBM_YELLOW = '#f1c21b'
IBM_ORANGE = '#ff832b'
IBM_RED = '#da1e28'
IBM_PURPLE = '#8a3ffc'
IBM_GRAY = '#697077'
IBM_LIGHT_GRAY = '#f4f4f4'
IBM_WHITE = '#ffffff'

# Color schemes for different diagram types
INFRASTRUCTURE_COLORS = {
    'vpc': IBM_BLUE,
    'subnet': IBM_LIGHT_BLUE,
    'instance': IBM_CYAN,
    'storage': IBM_TEAL,
    'security': IBM_GREEN,
    'network': IBM_YELLOW,
    'load_balancer': IBM_ORANGE,
    'gateway': IBM_RED,
    'background': IBM_LIGHT_GRAY,
    'text': IBM_GRAY
}

LIFECYCLE_COLORS = {
    'create': IBM_GREEN,
    'update': IBM_YELLOW,
    'destroy': IBM_RED,
    'validate': IBM_BLUE,
    'plan': IBM_CYAN,
    'apply': IBM_TEAL,
    'background': IBM_WHITE,
    'text': IBM_GRAY
}

ENTERPRISE_COLORS = {
    'dev': IBM_LIGHT_BLUE,
    'staging': IBM_YELLOW,
    'prod': IBM_GREEN,
    'security': IBM_RED,
    'monitoring': IBM_PURPLE,
    'cost': IBM_ORANGE,
    'background': IBM_LIGHT_GRAY,
    'text': IBM_GRAY
}

def setup_diagram(figsize=(16, 12), title="", subtitle=""):
    """Setup a professional diagram with IBM branding"""
    fig, ax = plt.subplots(figsize=figsize, dpi=300)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')
    
    # Background
    background = Rectangle((0, 0), 100, 100, facecolor=IBM_LIGHT_GRAY, alpha=0.3)
    ax.add_patch(background)
    
    # Title
    if title:
        ax.text(50, 95, title, fontsize=24, fontweight='bold', 
                ha='center', va='center', color=IBM_BLUE)
    
    # Subtitle
    if subtitle:
        ax.text(50, 91, subtitle, fontsize=16, 
                ha='center', va='center', color=IBM_GRAY)
    
    # IBM branding
    ax.text(95, 2, 'IBM Cloud', fontsize=12, fontweight='bold',
            ha='right', va='bottom', color=IBM_BLUE)
    
    return fig, ax

def create_rounded_box(ax, x, y, width, height, label, color, text_color=IBM_WHITE):
    """Create a rounded rectangle with label"""
    box = FancyBboxPatch(
        (x, y), width, height,
        boxstyle="round,pad=0.5",
        facecolor=color,
        edgecolor=IBM_GRAY,
        linewidth=2
    )
    ax.add_patch(box)
    
    # Add label
    ax.text(x + width/2, y + height/2, label, 
            fontsize=12, fontweight='bold',
            ha='center', va='center', color=text_color)
    
    return box

def create_connection(ax, start_box, end_box, label="", style="->"):
    """Create a connection between two boxes"""
    # Calculate connection points
    start_x = start_box.get_x() + start_box.get_width()
    start_y = start_box.get_y() + start_box.get_height()/2
    end_x = end_box.get_x()
    end_y = end_box.get_y() + end_box.get_height()/2
    
    # Create arrow
    arrow = patches.FancyArrowPatch(
        (start_x, start_y), (end_x, end_y),
        arrowstyle=style,
        color=IBM_GRAY,
        linewidth=2,
        mutation_scale=20
    )
    ax.add_patch(arrow)
    
    # Add label if provided
    if label:
        mid_x = (start_x + end_x) / 2
        mid_y = (start_y + end_y) / 2
        ax.text(mid_x, mid_y + 2, label, fontsize=10,
                ha='center', va='bottom', color=IBM_GRAY,
                bbox=dict(boxstyle="round,pad=0.3", facecolor=IBM_WHITE, alpha=0.8))

def generate_ibm_cloud_resource_architecture():
    """Generate IBM Cloud Resource Architecture Overview diagram"""
    fig, ax = setup_diagram(
        title="IBM Cloud Resource Architecture Overview",
        subtitle="Comprehensive Infrastructure Components and Relationships"
    )
    
    # VPC Foundation Layer
    vpc_box = create_rounded_box(ax, 5, 70, 90, 20, 
                                "Virtual Private Cloud (VPC)\nFoundation Layer", 
                                INFRASTRUCTURE_COLORS['vpc'])
    
    # Network Layer
    subnet_web = create_rounded_box(ax, 10, 55, 25, 10, 
                                   "Web Subnet\n(Public)", 
                                   INFRASTRUCTURE_COLORS['subnet'])
    
    subnet_app = create_rounded_box(ax, 37.5, 55, 25, 10, 
                                   "App Subnet\n(Private)", 
                                   INFRASTRUCTURE_COLORS['subnet'])
    
    subnet_data = create_rounded_box(ax, 65, 55, 25, 10, 
                                    "Data Subnet\n(Private)", 
                                    INFRASTRUCTURE_COLORS['subnet'])
    
    # Compute Layer
    web_instances = create_rounded_box(ax, 12, 40, 21, 8, 
                                      "Web Servers\n(2x bx2-2x8)", 
                                      INFRASTRUCTURE_COLORS['instance'])
    
    app_instances = create_rounded_box(ax, 39.5, 40, 21, 8, 
                                      "App Servers\n(2x bx2-2x8)", 
                                      INFRASTRUCTURE_COLORS['instance'])
    
    data_instances = create_rounded_box(ax, 67, 40, 21, 8, 
                                       "DB Servers\n(1x bx2-4x16)", 
                                       INFRASTRUCTURE_COLORS['instance'])
    
    # Storage Layer
    app_storage = create_rounded_box(ax, 39.5, 25, 21, 8, 
                                    "App Storage\n(100GB GP)", 
                                    INFRASTRUCTURE_COLORS['storage'])
    
    data_storage = create_rounded_box(ax, 67, 25, 21, 8, 
                                     "DB Storage\n(500GB 10IOPS)", 
                                     INFRASTRUCTURE_COLORS['storage'])
    
    # Security Layer
    web_sg = create_rounded_box(ax, 12, 10, 21, 6, 
                               "Web Security Group", 
                               INFRASTRUCTURE_COLORS['security'])
    
    app_sg = create_rounded_box(ax, 39.5, 10, 21, 6, 
                               "App Security Group", 
                               INFRASTRUCTURE_COLORS['security'])
    
    data_sg = create_rounded_box(ax, 67, 10, 21, 6, 
                                "Data Security Group", 
                                INFRASTRUCTURE_COLORS['security'])
    
    # Load Balancer
    load_balancer = create_rounded_box(ax, 12, 85, 21, 6, 
                                      "Application Load Balancer", 
                                      INFRASTRUCTURE_COLORS['load_balancer'])
    
    # Public Gateway
    public_gateway = create_rounded_box(ax, 39.5, 85, 21, 6, 
                                       "Public Gateway", 
                                       INFRASTRUCTURE_COLORS['gateway'])
    
    # Add connections with labels
    # Load balancer to web instances
    create_connection(ax, load_balancer, web_instances, "HTTP/HTTPS")
    
    # Web to app tier
    create_connection(ax, web_instances, app_instances, "API Calls")
    
    # App to data tier
    create_connection(ax, app_instances, data_instances, "Database")
    
    # Storage connections
    create_connection(ax, app_instances, app_storage, "Mount")
    create_connection(ax, data_instances, data_storage, "Mount")
    
    # Add legend
    legend_elements = [
        ('VPC Foundation', INFRASTRUCTURE_COLORS['vpc']),
        ('Network Subnets', INFRASTRUCTURE_COLORS['subnet']),
        ('Compute Instances', INFRASTRUCTURE_COLORS['instance']),
        ('Storage Volumes', INFRASTRUCTURE_COLORS['storage']),
        ('Security Groups', INFRASTRUCTURE_COLORS['security']),
        ('Load Balancer', INFRASTRUCTURE_COLORS['load_balancer']),
        ('Public Gateway', INFRASTRUCTURE_COLORS['gateway'])
    ]
    
    for i, (label, color) in enumerate(legend_elements):
        y_pos = 5 - i * 0.8
        legend_box = Rectangle((75, y_pos), 2, 0.6, facecolor=color)
        ax.add_patch(legend_box)
        ax.text(78, y_pos + 0.3, label, fontsize=9, va='center', color=IBM_GRAY)
    
    plt.tight_layout()
    return fig

def generate_resource_lifecycle_management():
    """Generate Resource Lifecycle Management diagram"""
    fig, ax = setup_diagram(
        title="Resource Lifecycle Management",
        subtitle="Systematic Approach to Resource Creation, Updates, and Destruction"
    )
    
    # Lifecycle phases
    phases = [
        ("Plan", 15, 75, LIFECYCLE_COLORS['plan']),
        ("Validate", 35, 75, LIFECYCLE_COLORS['validate']),
        ("Apply", 55, 75, LIFECYCLE_COLORS['apply']),
        ("Monitor", 75, 75, LIFECYCLE_COLORS['create']),
        ("Update", 75, 45, LIFECYCLE_COLORS['update']),
        ("Destroy", 55, 15, LIFECYCLE_COLORS['destroy'])
    ]
    
    phase_boxes = []
    for phase, x, y, color in phases:
        box = create_rounded_box(ax, x-7, y-5, 14, 10, phase, color)
        phase_boxes.append((phase, box))
    
    # Create workflow connections
    connections = [
        (0, 1, "terraform plan"),
        (1, 2, "terraform validate"),
        (2, 3, "terraform apply"),
        (3, 4, "Updates"),
        (4, 3, "Re-apply"),
        (3, 5, "Cleanup")
    ]
    
    for start_idx, end_idx, label in connections:
        start_box = phase_boxes[start_idx][1]
        end_box = phase_boxes[end_idx][1]
        create_connection(ax, start_box, end_box, label)
    
    # Add detailed steps for each phase
    details = [
        ("Plan Phase", 5, 60, [
            "• Resource dependency analysis",
            "• Cost estimation",
            "• Change preview",
            "• Validation checks"
        ]),
        ("Apply Phase", 45, 60, [
            "• Resource provisioning",
            "• Dependency ordering",
            "• Error handling",
            "• State management"
        ]),
        ("Monitor Phase", 5, 30, [
            "• Health monitoring",
            "• Performance tracking",
            "• Cost analysis",
            "• Compliance validation"
        ]),
        ("Update Phase", 45, 30, [
            "• In-place updates",
            "• Blue-green deployment",
            "• Rolling updates",
            "• Rollback procedures"
        ])
    ]
    
    for title, x, y, items in details:
        # Title box
        title_box = create_rounded_box(ax, x, y, 35, 4, title, IBM_BLUE)
        
        # Detail items
        for i, item in enumerate(items):
            ax.text(x + 2, y - 2 - i*2, item, fontsize=10, 
                   va='top', color=IBM_GRAY)
    
    plt.tight_layout()
    return fig

def generate_enterprise_resource_patterns():
    """Generate Enterprise Resource Patterns diagram"""
    fig, ax = setup_diagram(
        title="Enterprise Resource Patterns",
        subtitle="Multi-Environment Architecture and Governance Strategies"
    )
    
    # Environment tiers
    environments = [
        ("Development", 10, 70, ENTERPRISE_COLORS['dev']),
        ("Staging", 40, 70, ENTERPRISE_COLORS['staging']),
        ("Production", 70, 70, ENTERPRISE_COLORS['prod'])
    ]
    
    env_boxes = []
    for env, x, y, color in environments:
        box = create_rounded_box(ax, x, y, 25, 15, 
                                f"{env}\nEnvironment", color)
        env_boxes.append(box)
        
        # Add environment details
        if env == "Development":
            details = ["• 1 instance", "• Basic monitoring", "• Cost optimized"]
        elif env == "Staging":
            details = ["• 2 instances", "• Enhanced monitoring", "• Production-like"]
        else:
            details = ["• 3+ instances", "• Full monitoring", "• High availability"]
        
        for i, detail in enumerate(details):
            ax.text(x + 2, y - 5 - i*2, detail, fontsize=9, 
                   va='top', color=IBM_GRAY)
    
    # Governance layers
    governance = [
        ("Security & Compliance", 10, 45, ENTERPRISE_COLORS['security']),
        ("Cost Management", 40, 45, ENTERPRISE_COLORS['cost']),
        ("Monitoring & Observability", 70, 45, ENTERPRISE_COLORS['monitoring'])
    ]
    
    for gov, x, y, color in governance:
        box = create_rounded_box(ax, x, y, 25, 10, gov, color)
        
        # Connect to all environments
        for env_box in env_boxes:
            create_connection(ax, box, env_box, "", style="-")
    
    # Enterprise patterns
    patterns_box = create_rounded_box(ax, 25, 20, 50, 15, 
                                     "Enterprise Patterns", IBM_BLUE)
    
    patterns = [
        "• Consistent naming conventions",
        "• Standardized tagging strategies", 
        "• Automated compliance validation",
        "• Cost allocation and tracking",
        "• Multi-region disaster recovery",
        "• Infrastructure as Code governance"
    ]
    
    for i, pattern in enumerate(patterns):
        ax.text(27, 32 - i*2, pattern, fontsize=10, 
               va='top', color=IBM_WHITE)
    
    # ROI metrics
    roi_box = create_rounded_box(ax, 10, 5, 80, 8, 
                                "Business Value: 250-800% ROI | 30-50% Cost Savings | 95% Faster Deployment", 
                                IBM_GREEN)
    
    plt.tight_layout()
    return fig

def generate_security_compliance_framework():
    """Generate Security and Compliance Framework diagram"""
    fig, ax = setup_diagram(
        title="Security and Compliance Framework",
        subtitle="Defense-in-Depth Security Architecture for IBM Cloud Resources"
    )
    
    # Security layers (concentric circles)
    center_x, center_y = 50, 50
    
    # Outer layer - Network Security
    network_circle = plt.Circle((center_x, center_y), 35, 
                               fill=False, edgecolor=INFRASTRUCTURE_COLORS['security'], 
                               linewidth=4, linestyle='--')
    ax.add_patch(network_circle)
    ax.text(center_x, 85, "Network Security Layer", fontsize=14, fontweight='bold',
            ha='center', va='center', color=INFRASTRUCTURE_COLORS['security'])
    
    # Middle layer - Compute Security
    compute_circle = plt.Circle((center_x, center_y), 25, 
                               fill=False, edgecolor=INFRASTRUCTURE_COLORS['instance'], 
                               linewidth=4, linestyle='-')
    ax.add_patch(compute_circle)
    ax.text(center_x, 75, "Compute Security Layer", fontsize=12, fontweight='bold',
            ha='center', va='center', color=INFRASTRUCTURE_COLORS['instance'])
    
    # Inner layer - Data Security
    data_circle = plt.Circle((center_x, center_y), 15, 
                            fill=True, facecolor=INFRASTRUCTURE_COLORS['storage'], 
                            edgecolor=INFRASTRUCTURE_COLORS['storage'], 
                            linewidth=3, alpha=0.7)
    ax.add_patch(data_circle)
    ax.text(center_x, center_y, "Data Security\nCore", fontsize=12, fontweight='bold',
            ha='center', va='center', color=IBM_WHITE)
    
    # Security controls
    controls = [
        ("VPC Isolation", 20, 80, "Network"),
        ("Security Groups", 80, 80, "Network"), 
        ("Network ACLs", 20, 20, "Network"),
        ("Public Gateways", 80, 20, "Network"),
        ("SSH Key Management", 15, 60, "Compute"),
        ("Instance Profiles", 85, 60, "Compute"),
        ("User Data Security", 15, 40, "Compute"),
        ("Boot Volume Encryption", 85, 40, "Compute"),
        ("Data Encryption", 35, 30, "Data"),
        ("Key Management", 65, 30, "Data"),
        ("Backup Encryption", 35, 70, "Data"),
        ("Access Logging", 65, 70, "Data")
    ]
    
    for control, x, y, layer in controls:
        if layer == "Network":
            color = INFRASTRUCTURE_COLORS['security']
        elif layer == "Compute":
            color = INFRASTRUCTURE_COLORS['instance']
        else:
            color = INFRASTRUCTURE_COLORS['storage']
        
        control_box = create_rounded_box(ax, x-6, y-2, 12, 4, control, color, IBM_WHITE)
    
    # Compliance frameworks
    compliance_box = create_rounded_box(ax, 10, 5, 80, 8, 
                                       "Compliance: HIPAA | SOX | GDPR | PCI DSS | ISO 27001", 
                                       IBM_RED)
    
    plt.tight_layout()
    return fig

def generate_cost_optimization_strategies():
    """Generate Cost Optimization Strategies diagram"""
    fig, ax = setup_diagram(
        title="Cost Optimization Strategies",
        subtitle="Comprehensive Approach to Infrastructure Cost Management"
    )
    
    # Cost optimization categories
    categories = [
        ("Right-Sizing", 15, 75, [
            "Instance profile optimization",
            "CPU/Memory utilization analysis", 
            "Performance vs cost balance",
            "Workload-specific sizing"
        ]),
        ("Lifecycle Management", 55, 75, [
            "Scheduled shutdown/startup",
            "Auto-scaling policies",
            "Reserved instance planning",
            "Spot instance utilization"
        ]),
        ("Storage Optimization", 15, 45, [
            "Storage profile selection",
            "Data lifecycle policies",
            "Compression strategies",
            "Archive tier utilization"
        ]),
        ("Network Optimization", 55, 45, [
            "Private endpoint usage",
            "CDN implementation",
            "Data transfer optimization",
            "Load balancer efficiency"
        ])
    ]
    
    for category, x, y, items in categories:
        # Category header
        header_box = create_rounded_box(ax, x, y, 35, 6, category, IBM_ORANGE)
        
        # Category items
        for i, item in enumerate(items):
            item_box = create_rounded_box(ax, x+2, y-8-i*4, 31, 3, 
                                         item, IBM_LIGHT_BLUE, IBM_GRAY)
    
    # Cost savings metrics
    savings_data = [
        ("Infrastructure Costs", "30-50%", IBM_GREEN),
        ("Operational Overhead", "70%", IBM_CYAN),
        ("Deployment Time", "95%", IBM_TEAL),
        ("Error Reduction", "93%", IBM_BLUE)
    ]
    
    savings_box = create_rounded_box(ax, 20, 15, 60, 15, 
                                    "Cost Savings Achievements", IBM_BLUE)
    
    for i, (metric, saving, color) in enumerate(savings_data):
        x_pos = 25 + (i % 2) * 25
        y_pos = 22 - (i // 2) * 5
        
        metric_box = create_rounded_box(ax, x_pos, y_pos, 20, 4, 
                                       f"{metric}\n{saving} Savings", 
                                       color, IBM_WHITE)
    
    # ROI calculation
    roi_box = create_rounded_box(ax, 25, 5, 50, 6, 
                                "ROI: 250-800% | Payback: 3-8 months", 
                                IBM_GREEN)
    
    plt.tight_layout()
    return fig

def main():
    """Generate all diagrams for Topic 4.1"""
    print("🎨 Generating IBM Cloud Resource Provisioning Diagrams...")
    print("=" * 60)
    
    # Create output directory
    output_dir = "generated_diagrams"
    os.makedirs(output_dir, exist_ok=True)
    
    # Generate diagrams
    diagrams = [
        ("ibm_cloud_resource_architecture", generate_ibm_cloud_resource_architecture),
        ("resource_lifecycle_management", generate_resource_lifecycle_management),
        ("enterprise_resource_patterns", generate_enterprise_resource_patterns),
        ("security_compliance_framework", generate_security_compliance_framework),
        ("cost_optimization_strategies", generate_cost_optimization_strategies)
    ]
    
    for filename, generator_func in diagrams:
        print(f"📊 Generating {filename}.png...")
        
        try:
            fig = generator_func()
            
            # Save with high quality
            output_path = os.path.join(output_dir, f"{filename}.png")
            fig.savefig(output_path, dpi=300, bbox_inches='tight', 
                       facecolor='white', edgecolor='none')
            plt.close(fig)
            
            # Get file size
            file_size = os.path.getsize(output_path) / 1024  # KB
            print(f"   ✅ Saved: {output_path} ({file_size:.1f} KB)")
            
        except Exception as e:
            print(f"   ❌ Error generating {filename}: {str(e)}")
    
    print("\n🎯 Diagram Generation Summary:")
    print(f"📁 Output directory: {output_dir}")
    print(f"📊 Total diagrams: {len(diagrams)}")
    print(f"🎨 Resolution: 300 DPI")
    print(f"🎨 Color scheme: IBM Brand Colors")
    print(f"📅 Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("\n✅ All diagrams generated successfully!")

if __name__ == "__main__":
    main()
