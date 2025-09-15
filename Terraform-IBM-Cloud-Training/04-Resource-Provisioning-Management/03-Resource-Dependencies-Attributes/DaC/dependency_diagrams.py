#!/usr/bin/env python3
"""
Resource Dependencies and Attributes - Diagram Generation Script
Topic 4.3: Advanced Dependency Management in IBM Cloud Terraform

This script generates 5 professional diagrams for dependency management concepts:
1. Dependency Types and Relationships
2. Resource Attribute Flow and References
3. Data Source Integration Patterns
4. Multi-Tier Architecture Dependencies
5. Dependency Graph Optimization

All diagrams are generated at 300 DPI with IBM brand colors for enterprise presentations.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, ConnectionPatch, Circle
import numpy as np
import os

# IBM Brand Colors
IBM_BLUE = '#0f62fe'
IBM_BLUE_60 = '#4589ff'
IBM_BLUE_30 = '#a6c8ff'
IBM_BLUE_10 = '#edf5ff'
IBM_GRAY_100 = '#161616'
IBM_GRAY_70 = '#525252'
IBM_GRAY_50 = '#8d8d8d'
IBM_GRAY_30 = '#c6c6c6'
IBM_GRAY_10 = '#f4f4f4'
IBM_RED = '#da1e28'
IBM_GREEN = '#24a148'
IBM_YELLOW = '#f1c21b'
IBM_PURPLE = '#8a3ffc'
IBM_CYAN = '#1192e8'
IBM_ORANGE = '#ff832b'

def setup_diagram(figsize=(16, 12), title="", subtitle=""):
    """Setup a professional diagram with IBM styling"""
    fig, ax = plt.subplots(figsize=figsize, dpi=300)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')
    
    # Add title
    if title:
        fig.suptitle(title, fontsize=24, fontweight='bold', color=IBM_GRAY_100, y=0.95)
    if subtitle:
        ax.text(50, 95, subtitle, ha='center', va='top', fontsize=16, 
                color=IBM_GRAY_70, style='italic')
    
    # Add IBM branding
    ax.text(2, 2, 'IBM Cloud Terraform Training', fontsize=10, 
            color=IBM_GRAY_50, alpha=0.7)
    ax.text(98, 2, 'Topic 4.3: Dependencies & Attributes', fontsize=10, 
            color=IBM_GRAY_50, alpha=0.7, ha='right')
    
    return fig, ax

def create_rounded_box(ax, x, y, width, height, text, color=IBM_BLUE, text_color='white', 
                      fontsize=12, style='round,pad=0.3'):
    """Create a rounded rectangle with text"""
    box = FancyBboxPatch((x, y), width, height,
                        boxstyle=style,
                        facecolor=color,
                        edgecolor=IBM_GRAY_70,
                        linewidth=1.5)
    ax.add_patch(box)
    
    ax.text(x + width/2, y + height/2, text, ha='center', va='center',
            fontsize=fontsize, color=text_color, weight='bold', wrap=True)
    
    return box

def create_arrow(ax, start, end, color=IBM_GRAY_70, style='->', linewidth=2, label=''):
    """Create an arrow between two points"""
    arrow = ConnectionPatch(start, end, "data", "data",
                          arrowstyle=style, shrinkA=5, shrinkB=5,
                          color=color, linewidth=linewidth)
    ax.add_patch(arrow)
    
    if label:
        mid_x = (start[0] + end[0]) / 2
        mid_y = (start[1] + end[1]) / 2
        ax.text(mid_x, mid_y + 2, label, ha='center', va='bottom',
                fontsize=10, color=color, weight='bold',
                bbox=dict(boxstyle="round,pad=0.3", facecolor='white', alpha=0.8))

def diagram_1_dependency_types():
    """Diagram 1: Dependency Types and Relationships"""
    fig, ax = setup_diagram(title="Dependency Types and Relationships",
                           subtitle="Understanding Implicit vs Explicit Dependencies in Terraform")
    
    # Implicit Dependencies Section
    ax.text(25, 85, 'Implicit Dependencies', ha='center', va='center',
            fontsize=18, color=IBM_BLUE, weight='bold')
    
    # VPC Resource
    create_rounded_box(ax, 10, 70, 30, 8, 'ibm_is_vpc.main', IBM_BLUE)
    
    # Subnet Resource (implicit dependency)
    create_rounded_box(ax, 10, 55, 30, 8, 'ibm_is_subnet.web\nvpc = ibm_is_vpc.main.id', IBM_BLUE_60)
    
    # Instance Resource (implicit dependency)
    create_rounded_box(ax, 10, 40, 30, 8, 'ibm_is_instance.web\nsubnet = ibm_is_subnet.web.id', IBM_BLUE_30)
    
    # Arrows showing implicit dependencies
    create_arrow(ax, (25, 70), (25, 63), IBM_GREEN, label='Implicit')
    create_arrow(ax, (25, 55), (25, 48), IBM_GREEN, label='Implicit')
    
    # Explicit Dependencies Section
    ax.text(75, 85, 'Explicit Dependencies', ha='center', va='center',
            fontsize=18, color=IBM_RED, weight='bold')
    
    # Database Resource
    create_rounded_box(ax, 60, 70, 30, 8, 'ibm_database.app_db', IBM_RED)
    
    # App Server Resource (explicit dependency)
    create_rounded_box(ax, 60, 55, 30, 8, 'ibm_is_instance.app\ndepends_on = [ibm_database.app_db]', IBM_ORANGE)
    
    # Web Server Resource (explicit dependency)
    create_rounded_box(ax, 60, 40, 30, 8, 'ibm_is_instance.web\ndepends_on = [ibm_is_instance.app]', IBM_YELLOW)
    
    # Arrows showing explicit dependencies
    create_arrow(ax, (75, 70), (75, 63), IBM_RED, label='Explicit')
    create_arrow(ax, (75, 55), (75, 48), IBM_RED, label='Explicit')
    
    # Comparison Table
    ax.text(50, 30, 'Dependency Comparison', ha='center', va='center',
            fontsize=16, color=IBM_GRAY_100, weight='bold')
    
    # Table headers
    table_data = [
        ['Aspect', 'Implicit Dependencies', 'Explicit Dependencies'],
        ['Detection', 'Automatic via references', 'Manual specification'],
        ['Maintenance', 'Self-maintaining', 'Requires manual updates'],
        ['Performance', 'Optimal parallelization', 'May limit parallelization'],
        ['Use Case', 'Resource attribute references', 'Timing/ordering requirements'],
        ['Best Practice', 'Preferred when possible', 'Use sparingly']
    ]
    
    for i, row in enumerate(table_data):
        y_pos = 25 - i * 3
        for j, cell in enumerate(row):
            x_pos = 15 + j * 25
            color = IBM_GRAY_10 if i == 0 else 'white'
            text_color = IBM_GRAY_100 if i == 0 else IBM_GRAY_70
            weight = 'bold' if i == 0 else 'normal'
            
            create_rounded_box(ax, x_pos, y_pos, 23, 2.5, cell, color, text_color, 
                             fontsize=10, style='round,pad=0.1')
    
    plt.tight_layout()
    return fig

def diagram_2_resource_attributes():
    """Diagram 2: Resource Attribute Flow and References"""
    fig, ax = setup_diagram(title="Resource Attribute Flow and References",
                           subtitle="How Resource Attributes Enable Dynamic Cross-Resource Communication")
    
    # VPC Resource with Attributes
    vpc_box = create_rounded_box(ax, 10, 75, 25, 15, 
                                'ibm_is_vpc.main\n\nAttributes:\n• id\n• name\n• crn\n• status', 
                                IBM_BLUE)
    
    # Subnet Resource using VPC attributes
    subnet_box = create_rounded_box(ax, 45, 75, 25, 15,
                                   'ibm_is_subnet.web\n\nReferences:\nvpc = ibm_is_vpc.main.id\n\nAttributes:\n• id\n• zone',
                                   IBM_BLUE_60)
    
    # Instance Resource using multiple attributes
    instance_box = create_rounded_box(ax, 80, 75, 15, 15,
                                     'ibm_is_instance.web\n\nReferences:\nvpc = vpc.id\nsubnet = subnet.id',
                                     IBM_BLUE_30)
    
    # Attribute flow arrows
    create_arrow(ax, (35, 82.5), (45, 82.5), IBM_GREEN, label='vpc.id')
    create_arrow(ax, (70, 82.5), (80, 82.5), IBM_GREEN, label='subnet.id')
    
    # Load Balancer using instance attributes
    lb_box = create_rounded_box(ax, 25, 50, 30, 12,
                               'ibm_is_lb_pool_member\n\nReferences:\ntarget = instance.primary_network_interface[0].primary_ipv4_address',
                               IBM_PURPLE)
    
    # Arrow from instance to load balancer
    create_arrow(ax, (87.5, 75), (40, 62), IBM_PURPLE, label='instance.ip')
    
    # Attribute Reference Patterns
    ax.text(50, 35, 'Common Attribute Reference Patterns', ha='center', va='center',
            fontsize=16, color=IBM_GRAY_100, weight='bold')
    
    patterns = [
        ('VPC → Subnet', 'vpc = ibm_is_vpc.main.id', IBM_BLUE),
        ('Subnet → Instance', 'subnet = ibm_is_subnet.web.id', IBM_BLUE_60),
        ('Instance → LB Member', 'target = instance.primary_network_interface[0].primary_ipv4_address', IBM_PURPLE),
        ('Security Group → Rule', 'group = ibm_is_security_group.web.id', IBM_CYAN),
        ('Database → App Config', 'db_url = ibm_database.main.connectionstrings[0].composed', IBM_GREEN)
    ]
    
    for i, (pattern, code, color) in enumerate(patterns):
        y_pos = 28 - i * 4
        create_rounded_box(ax, 10, y_pos, 20, 3, pattern, color, fontsize=10)
        create_rounded_box(ax, 35, y_pos, 55, 3, code, IBM_GRAY_10, IBM_GRAY_100, fontsize=9)
    
    plt.tight_layout()
    return fig

def diagram_3_data_sources():
    """Diagram 3: Data Source Integration Patterns"""
    fig, ax = setup_diagram(title="Data Source Integration Patterns",
                           subtitle="Dynamic Infrastructure Discovery and Environment-Agnostic Configurations")
    
    # Existing Infrastructure (Data Sources)
    ax.text(20, 90, 'Existing Infrastructure', ha='center', va='center',
            fontsize=16, color=IBM_GRAY_100, weight='bold')
    
    # Data source boxes
    data_sources = [
        ('data.ibm_is_vpc.existing', 'Existing VPC', 85),
        ('data.ibm_is_subnets.existing', 'Existing Subnets', 80),
        ('data.ibm_is_image.ubuntu', 'Latest Ubuntu Image', 75),
        ('data.ibm_resource_group.project', 'Resource Group', 70)
    ]
    
    for name, desc, y in data_sources:
        create_rounded_box(ax, 5, y, 30, 4, f'{name}\n{desc}', IBM_CYAN, fontsize=10)
    
    # Local Values Processing
    ax.text(50, 90, 'Local Values Processing', ha='center', va='center',
            fontsize=16, color=IBM_GRAY_100, weight='bold')
    
    create_rounded_box(ax, 40, 75, 20, 12,
                      'locals {\n  vpc_id = data.vpc.id\n  subnet_ids = data.subnets[*].id\n  image_id = data.image.id\n}',
                      IBM_GRAY_30, IBM_GRAY_100, fontsize=9)
    
    # New Resources Using Data Sources
    ax.text(80, 90, 'New Resources', ha='center', va='center',
            fontsize=16, color=IBM_GRAY_100, weight='bold')
    
    new_resources = [
        ('ibm_is_instance.web', 'Web Servers', 85),
        ('ibm_is_security_group.app', 'Security Groups', 80),
        ('ibm_database.main', 'Database Services', 75),
        ('ibm_is_lb.public', 'Load Balancers', 70)
    ]
    
    for name, desc, y in new_resources:
        create_rounded_box(ax, 70, y, 25, 4, f'{name}\n{desc}', IBM_GREEN, fontsize=10)
    
    # Data flow arrows
    create_arrow(ax, (35, 82), (40, 82), IBM_BLUE, label='Query')
    create_arrow(ax, (60, 82), (70, 82), IBM_GREEN, label='Reference')
    
    # Conditional Logic Example
    ax.text(50, 55, 'Conditional Logic with Data Sources', ha='center', va='center',
            fontsize=16, color=IBM_GRAY_100, weight='bold')
    
    conditional_code = '''locals {
  vpc_id = var.use_existing_vpc ? 
    data.ibm_is_vpc.existing[0].id : 
    ibm_is_vpc.new.id
    
  subnet_ids = var.use_existing_vpc ? 
    [for subnet in data.ibm_is_subnets.existing[0].subnets : 
     subnet.id if can(regex("web", subnet.name))] :
    ibm_is_subnet.new[*].id
}'''
    
    create_rounded_box(ax, 15, 35, 70, 15, conditional_code, IBM_GRAY_10, IBM_GRAY_100, fontsize=10)
    
    # Benefits
    benefits = [
        'Environment Flexibility', 'Reduced Hardcoding', 'Dynamic Adaptation', 
        'Integration Ready', 'Cost Optimization'
    ]
    
    for i, benefit in enumerate(benefits):
        x_pos = 10 + i * 16
        create_rounded_box(ax, x_pos, 15, 14, 6, benefit, IBM_BLUE_30, IBM_GRAY_100, fontsize=10)
    
    plt.tight_layout()
    return fig

def diagram_4_multi_tier_architecture():
    """Diagram 4: Multi-Tier Architecture Dependencies"""
    fig, ax = setup_diagram(title="Multi-Tier Architecture Dependencies",
                           subtitle="Complex Dependency Management in Enterprise Applications")
    
    # Foundation Layer
    ax.text(50, 95, 'Foundation Layer', ha='center', va='center',
            fontsize=16, color=IBM_GRAY_100, weight='bold')
    
    create_rounded_box(ax, 20, 88, 60, 5, 'VPC • Subnets • Security Groups • Gateways', IBM_GRAY_30, IBM_GRAY_100)
    
    # Shared Services Layer
    ax.text(15, 80, 'Shared Services', ha='center', va='center',
            fontsize=14, color=IBM_GRAY_100, weight='bold')
    
    shared_services = [
        ('Monitoring\n(Sysdig)', 75, IBM_PURPLE),
        ('Logging\n(LogDNA)', 70, IBM_PURPLE),
        ('Backup\n(COS)', 65, IBM_PURPLE),
        ('DNS\n(CIS)', 60, IBM_PURPLE)
    ]
    
    for service, y, color in shared_services:
        create_rounded_box(ax, 5, y, 20, 4, service, color, fontsize=10)
    
    # Data Tier
    ax.text(50, 80, 'Data Tier', ha='center', va='center',
            fontsize=14, color=IBM_GRAY_100, weight='bold')
    
    create_rounded_box(ax, 35, 70, 15, 8, 'PostgreSQL\nPrimary', IBM_RED)
    create_rounded_box(ax, 55, 70, 15, 8, 'PostgreSQL\nReplica', IBM_ORANGE)
    create_rounded_box(ax, 75, 70, 15, 8, 'Redis\nCache', IBM_YELLOW)
    
    # Application Tier
    ax.text(50, 60, 'Application Tier', ha='center', va='center',
            fontsize=14, color=IBM_GRAY_100, weight='bold')
    
    for i in range(3):
        x_pos = 35 + i * 15
        create_rounded_box(ax, x_pos, 50, 12, 6, f'App\nServer\n{i+1}', IBM_BLUE_60)
    
    create_rounded_box(ax, 75, 50, 15, 6, 'Internal\nLoad Balancer', IBM_CYAN)
    
    # Presentation Tier
    ax.text(50, 40, 'Presentation Tier', ha='center', va='center',
            fontsize=14, color=IBM_GRAY_100, weight='bold')
    
    for i in range(2):
        x_pos = 40 + i * 15
        create_rounded_box(ax, x_pos, 30, 12, 6, f'Web\nServer\n{i+1}', IBM_BLUE)
    
    create_rounded_box(ax, 75, 30, 15, 6, 'Public\nLoad Balancer', IBM_GREEN)
    
    # Dependency arrows
    # Foundation to all tiers
    create_arrow(ax, (50, 88), (50, 78), IBM_GRAY_70, label='Foundation')
    
    # Shared services to all tiers
    create_arrow(ax, (25, 72), (35, 72), IBM_PURPLE, style='-')
    create_arrow(ax, (25, 53), (35, 53), IBM_PURPLE, style='-')
    create_arrow(ax, (25, 33), (40, 33), IBM_PURPLE, style='-')
    
    # Data to Application
    create_arrow(ax, (50, 70), (50, 56), IBM_RED, label='DB Connection')
    
    # Application to Presentation
    create_arrow(ax, (50, 50), (50, 36), IBM_BLUE_60, label='API Calls')
    
    # Load balancer connections
    create_arrow(ax, (75, 50), (60, 53), IBM_CYAN, style='-')
    create_arrow(ax, (75, 30), (60, 33), IBM_GREEN, style='-')
    
    # Dependency Timeline
    ax.text(50, 20, 'Deployment Order', ha='center', va='center',
            fontsize=14, color=IBM_GRAY_100, weight='bold')
    
    timeline = [
        '1. Foundation', '2. Shared Services', '3. Data Tier', 
        '4. Application Tier', '5. Presentation Tier'
    ]
    
    for i, step in enumerate(timeline):
        x_pos = 10 + i * 18
        create_rounded_box(ax, x_pos, 10, 16, 5, step, IBM_BLUE_30, IBM_GRAY_100, fontsize=10)
        if i < len(timeline) - 1:
            create_arrow(ax, (x_pos + 16, 12.5), (x_pos + 18, 12.5), IBM_GRAY_70, style='->')
    
    plt.tight_layout()
    return fig

def diagram_5_optimization():
    """Diagram 5: Dependency Graph Optimization"""
    fig, ax = setup_diagram(title="Dependency Graph Optimization",
                           subtitle="Performance Optimization and Parallel Execution Strategies")
    
    # Before Optimization (Left Side)
    ax.text(25, 90, 'Before Optimization', ha='center', va='center',
            fontsize=16, color=IBM_RED, weight='bold')
    
    # Sequential dependency chain
    resources_before = [
        ('VPC', 80, IBM_BLUE),
        ('Subnet 1', 75, IBM_BLUE_60),
        ('Subnet 2', 70, IBM_BLUE_60),
        ('Subnet 3', 65, IBM_BLUE_60),
        ('SG 1', 60, IBM_CYAN),
        ('SG 2', 55, IBM_CYAN),
        ('Instance 1', 50, IBM_GREEN),
        ('Instance 2', 45, IBM_GREEN)
    ]
    
    for i, (name, y, color) in enumerate(resources_before):
        create_rounded_box(ax, 15, y, 20, 4, name, color, fontsize=10)
        if i < len(resources_before) - 1:
            create_arrow(ax, (25, y), (25, y - 1), IBM_RED, style='->')
    
    # Time indicator
    ax.text(5, 62.5, 'Time:\n25 min', ha='center', va='center',
            fontsize=12, color=IBM_RED, weight='bold')
    
    # After Optimization (Right Side)
    ax.text(75, 90, 'After Optimization', ha='center', va='center',
            fontsize=16, color=IBM_GREEN, weight='bold')
    
    # Parallel execution
    create_rounded_box(ax, 65, 80, 20, 4, 'VPC', IBM_BLUE, fontsize=10)
    
    # Parallel subnets
    for i in range(3):
        x_pos = 60 + i * 8
        create_rounded_box(ax, x_pos, 72, 7, 4, f'Subnet\n{i+1}', IBM_BLUE_60, fontsize=9)
        create_arrow(ax, (75, 80), (x_pos + 3.5, 76), IBM_GREEN, style='->')
    
    # Parallel security groups
    for i in range(2):
        x_pos = 65 + i * 10
        create_rounded_box(ax, x_pos, 64, 8, 4, f'SG {i+1}', IBM_CYAN, fontsize=9)
        create_arrow(ax, (75, 80), (x_pos + 4, 68), IBM_GREEN, style='->')
    
    # Parallel instances
    for i in range(2):
        x_pos = 65 + i * 10
        create_rounded_box(ax, x_pos, 56, 8, 4, f'Instance\n{i+1}', IBM_GREEN, fontsize=9)
        create_arrow(ax, (x_pos + 4, 64), (x_pos + 4, 60), IBM_GREEN, style='->')
    
    # Time indicator
    ax.text(95, 68, 'Time:\n8 min', ha='center', va='center',
            fontsize=12, color=IBM_GREEN, weight='bold')
    
    # Optimization Strategies
    ax.text(50, 45, 'Optimization Strategies', ha='center', va='center',
            fontsize=16, color=IBM_GRAY_100, weight='bold')
    
    strategies = [
        ('Minimize Explicit Dependencies', 'Use implicit dependencies when possible', IBM_BLUE),
        ('Parallel Resource Creation', 'Group independent resources for parallel execution', IBM_GREEN),
        ('Module Organization', 'Organize related resources in modules', IBM_PURPLE),
        ('Data Source Optimization', 'Cache data source results in locals', IBM_CYAN),
        ('Dependency Batching', 'Batch related operations together', IBM_ORANGE)
    ]
    
    for i, (title, desc, color) in enumerate(strategies):
        y_pos = 38 - i * 6
        create_rounded_box(ax, 10, y_pos, 25, 4, title, color, fontsize=10)
        create_rounded_box(ax, 40, y_pos, 50, 4, desc, IBM_GRAY_10, IBM_GRAY_100, fontsize=10)
    
    # Performance Metrics
    ax.text(50, 8, 'Performance Impact', ha='center', va='center',
            fontsize=14, color=IBM_GRAY_100, weight='bold')
    
    metrics = [
        ('Deployment Time', '68% Reduction'),
        ('Resource Failures', '85% Reduction'),
        ('Troubleshooting', '75% Faster'),
        ('Scalability', '10x Improvement')
    ]
    
    for i, (metric, improvement) in enumerate(metrics):
        x_pos = 15 + i * 20
        create_rounded_box(ax, x_pos, 2, 18, 4, f'{metric}\n{improvement}', IBM_BLUE_30, IBM_GRAY_100, fontsize=10)
    
    plt.tight_layout()
    return fig

def main():
    """Generate all dependency management diagrams"""
    # Create output directory
    output_dir = "generated_diagrams"
    os.makedirs(output_dir, exist_ok=True)
    
    # Generate all diagrams
    diagrams = [
        (diagram_1_dependency_types, "01_dependency_types_relationships.png"),
        (diagram_2_resource_attributes, "02_resource_attribute_flow.png"),
        (diagram_3_data_sources, "03_data_source_integration.png"),
        (diagram_4_multi_tier_architecture, "04_multi_tier_dependencies.png"),
        (diagram_5_optimization, "05_dependency_optimization.png")
    ]
    
    total_size = 0
    
    for diagram_func, filename in diagrams:
        print(f"Generating {filename}...")
        fig = diagram_func()
        
        # Save with high quality
        filepath = os.path.join(output_dir, filename)
        fig.savefig(filepath, dpi=300, bbox_inches='tight', 
                   facecolor='white', edgecolor='none')
        plt.close(fig)
        
        # Calculate file size
        size = os.path.getsize(filepath)
        total_size += size
        print(f"  Saved: {filename} ({size/1024:.1f} KB)")
    
    print(f"\nAll diagrams generated successfully!")
    print(f"Total size: {total_size/1024/1024:.1f} MB")
    print(f"Output directory: {output_dir}/")
    
    # Generate summary
    print("\nDiagram Summary:")
    print("1. Dependency Types & Relationships - Implicit vs explicit dependency patterns")
    print("2. Resource Attribute Flow - Cross-resource communication and references")
    print("3. Data Source Integration - Dynamic discovery and conditional logic")
    print("4. Multi-Tier Dependencies - Complex enterprise architecture patterns")
    print("5. Dependency Optimization - Performance tuning and parallel execution")

if __name__ == "__main__":
    main()
