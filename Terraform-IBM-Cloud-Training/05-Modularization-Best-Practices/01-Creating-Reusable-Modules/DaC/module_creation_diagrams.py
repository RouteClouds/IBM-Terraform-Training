#!/usr/bin/env python3
"""
Professional Diagram Generation for Terraform Module Creation
IBM Cloud Terraform Training - Topic 5.1: Creating Reusable Modules

This script generates 5 high-quality diagrams (300 DPI) illustrating module creation concepts,
patterns, and best practices for enterprise IBM Cloud Terraform deployments.

Author: IBM Cloud Terraform Training Program
Version: 1.0.0
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, ConnectionPatch, Circle
import numpy as np
import os
from datetime import datetime

# IBM Brand Colors
COLORS = {
    'primary': '#0f62fe',      # IBM Blue
    'secondary': '#393939',    # IBM Gray
    'accent': '#ff832b',       # IBM Orange
    'success': '#24a148',      # IBM Green
    'warning': '#f1c21b',      # IBM Yellow
    'background': '#f4f4f4',   # Light Gray
    'text': '#161616',         # Dark Gray
    'white': '#ffffff',
    'light_blue': '#a6c8ff',
    'light_gray': '#e0e0e0',
    'dark_blue': '#002d9c'
}

def setup_diagram(figsize=(16, 12), title="", subtitle=""):
    """Setup a professional diagram with IBM branding"""
    fig, ax = plt.subplots(figsize=figsize, dpi=300)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')
    
    # Background
    fig.patch.set_facecolor(COLORS['background'])
    
    # Title
    if title:
        ax.text(50, 95, title, fontsize=24, fontweight='bold', 
                ha='center', va='center', color=COLORS['text'])
    
    if subtitle:
        ax.text(50, 90, subtitle, fontsize=16, ha='center', va='center', 
                color=COLORS['secondary'], style='italic')
    
    return fig, ax

def create_rounded_box(ax, x, y, width, height, text, color, text_color='white', fontsize=12):
    """Create a rounded rectangle with text"""
    box = FancyBboxPatch(
        (x, y), width, height,
        boxstyle="round,pad=0.5",
        facecolor=color,
        edgecolor=COLORS['secondary'],
        linewidth=2
    )
    ax.add_patch(box)
    
    ax.text(x + width/2, y + height/2, text, fontsize=fontsize, fontweight='bold',
            ha='center', va='center', color=text_color, wrap=True)
    
    return box

def create_arrow(ax, start, end, color=COLORS['primary'], style='->', linewidth=3):
    """Create a professional arrow between two points"""
    arrow = ConnectionPatch(start, end, "data", "data",
                          arrowstyle=style, shrinkA=5, shrinkB=5,
                          mutation_scale=20, fc=color, ec=color, linewidth=linewidth)
    ax.add_patch(arrow)
    return arrow

def diagram_1_module_architecture():
    """Generate Figure 5.1: Module Architecture and Composition Patterns"""
    fig, ax = setup_diagram(
        title="Module Architecture and Composition Patterns",
        subtitle="Enterprise-grade module design with IBM Cloud integration"
    )
    
    # Module Structure
    create_rounded_box(ax, 5, 70, 25, 15, "Module Interface\n• Variables\n• Validation\n• Outputs", 
                      COLORS['primary'], fontsize=11)
    
    create_rounded_box(ax, 35, 70, 25, 15, "Resource Logic\n• IBM Cloud Resources\n• Data Sources\n• Locals", 
                      COLORS['accent'], fontsize=11)
    
    create_rounded_box(ax, 65, 70, 30, 15, "Enterprise Features\n• Governance\n• Compliance\n• Cost Optimization", 
                      COLORS['success'], fontsize=11)
    
    # Composition Patterns
    create_rounded_box(ax, 10, 45, 20, 12, "Foundational\nModules\n• VPC\n• Security", 
                      COLORS['light_blue'], COLORS['text'], fontsize=10)
    
    create_rounded_box(ax, 40, 45, 20, 12, "Composite\nModules\n• Applications\n• Environments", 
                      COLORS['warning'], COLORS['text'], fontsize=10)
    
    create_rounded_box(ax, 70, 45, 20, 12, "Utility\nModules\n• Naming\n• Tagging", 
                      COLORS['light_gray'], COLORS['text'], fontsize=10)
    
    # IBM Cloud Services
    services = ["VPC", "Compute", "Storage", "Database", "Security", "Monitoring"]
    for i, service in enumerate(services):
        x = 10 + (i * 13)
        create_rounded_box(ax, x, 20, 12, 8, service, COLORS['secondary'], fontsize=9)
    
    # Arrows showing relationships
    create_arrow(ax, (17.5, 70), (17.5, 57))
    create_arrow(ax, (47.5, 70), (47.5, 57))
    create_arrow(ax, (80, 70), (80, 57))
    
    # Module Registry
    create_rounded_box(ax, 25, 5, 50, 10, "Module Registry & Distribution\nVersioning • Testing • Documentation • Governance", 
                      COLORS['dark_blue'], fontsize=12)
    
    # Arrows to registry
    for x in [20, 50, 80]:
        create_arrow(ax, (x, 45), (50, 15))
    
    # Add legend
    ax.text(5, 35, "Module Components:", fontsize=14, fontweight='bold', color=COLORS['text'])
    ax.text(5, 32, "• Interface: Variables, validation, outputs", fontsize=10, color=COLORS['text'])
    ax.text(5, 29, "• Logic: Resources, data sources, computations", fontsize=10, color=COLORS['text'])
    ax.text(5, 26, "• Enterprise: Governance, compliance, optimization", fontsize=10, color=COLORS['text'])
    
    plt.tight_layout()
    return fig

def diagram_2_interface_design():
    """Generate Figure 5.2: Module Interface Design and Data Flow"""
    fig, ax = setup_diagram(
        title="Module Interface Design and Data Flow",
        subtitle="Variable validation, type constraints, and output strategies"
    )
    
    # Input Variables Section
    create_rounded_box(ax, 5, 75, 25, 18, "Input Variables\n• Type Constraints\n• Validation Rules\n• Default Values\n• Documentation", 
                      COLORS['primary'], fontsize=11)
    
    # Variable Types
    types = [
        ("string", 8, 65),
        ("number", 8, 60),
        ("bool", 8, 55),
        ("object", 20, 65),
        ("list", 20, 60),
        ("map", 20, 55)
    ]
    
    for var_type, x, y in types:
        create_rounded_box(ax, x, y, 8, 4, var_type, COLORS['light_blue'], COLORS['text'], fontsize=9)
    
    # Validation Engine
    create_rounded_box(ax, 40, 75, 20, 18, "Validation Engine\n• Business Rules\n• Format Checking\n• Range Validation\n• Custom Logic", 
                      COLORS['warning'], COLORS['text'], fontsize=11)
    
    # Resource Processing
    create_rounded_box(ax, 70, 75, 25, 18, "Resource Processing\n• IBM Cloud APIs\n• Resource Creation\n• Dependency Mgmt\n• State Management", 
                      COLORS['accent'], fontsize=11)
    
    # Data Flow
    create_arrow(ax, (30, 84), (40, 84))
    create_arrow(ax, (60, 84), (70, 84))
    
    # Local Values
    create_rounded_box(ax, 15, 45, 30, 12, "Local Values & Computations\n• Tag Generation\n• Name Construction\n• Conditional Logic\n• Data Transformation", 
                      COLORS['success'], fontsize=10)
    
    # Outputs Section
    create_rounded_box(ax, 55, 45, 35, 12, "Module Outputs\n• Resource IDs & Attributes\n• Integration Endpoints\n• Cost Information\n• Metadata", 
                      COLORS['secondary'], fontsize=10)
    
    # Data Sources
    create_rounded_box(ax, 5, 25, 40, 12, "Data Sources\n• Existing Resources\n• Account Information\n• Regional Data\n• Service Catalogs", 
                      COLORS['light_gray'], COLORS['text'], fontsize=10)
    
    # IBM Cloud Services
    create_rounded_box(ax, 55, 25, 35, 12, "IBM Cloud Services\n• VPC Infrastructure\n• Compute Services\n• Storage Solutions\n• Security Services", 
                      COLORS['dark_blue'], fontsize=10)
    
    # Flow arrows
    create_arrow(ax, (30, 75), (30, 57))
    create_arrow(ax, (82.5, 75), (72.5, 57))
    create_arrow(ax, (25, 45), (25, 37))
    create_arrow(ax, (72.5, 45), (72.5, 37))
    
    # Error Handling
    create_rounded_box(ax, 25, 5, 50, 10, "Error Handling & Validation Feedback\nMeaningful Messages • Remediation Guidance • Debug Information", 
                      COLORS['warning'], COLORS['text'], fontsize=11)
    
    plt.tight_layout()
    return fig

def diagram_3_versioning_lifecycle():
    """Generate Figure 5.3: Versioning and Lifecycle Management"""
    fig, ax = setup_diagram(
        title="Versioning and Lifecycle Management",
        subtitle="Semantic versioning, backward compatibility, and release workflows"
    )
    
    # Development Lifecycle
    stages = [
        ("Development", 10, 80, COLORS['primary']),
        ("Testing", 30, 80, COLORS['warning']),
        ("Release", 50, 80, COLORS['success']),
        ("Maintenance", 70, 80, COLORS['accent']),
        ("Retirement", 90, 80, COLORS['secondary'])
    ]
    
    for stage, x, y, color in stages:
        create_rounded_box(ax, x-5, y-5, 10, 10, stage, color, fontsize=10)
    
    # Connect stages with arrows
    for i in range(len(stages)-1):
        start_x = stages[i][1] + 5
        end_x = stages[i+1][1] - 5
        create_arrow(ax, (start_x, 80), (end_x, 80))
    
    # Semantic Versioning
    create_rounded_box(ax, 5, 60, 90, 12, "Semantic Versioning (MAJOR.MINOR.PATCH)\nMAJOR: Breaking changes • MINOR: New features • PATCH: Bug fixes", 
                      COLORS['light_blue'], COLORS['text'], fontsize=12)
    
    # Version Examples
    versions = [
        ("v1.0.0", "Initial Release", 15, 45),
        ("v1.1.0", "New Features", 35, 45),
        ("v1.1.1", "Bug Fixes", 55, 45),
        ("v2.0.0", "Breaking Changes", 75, 45)
    ]
    
    for version, desc, x, y in versions:
        create_rounded_box(ax, x-7, y-3, 14, 6, f"{version}\n{desc}", COLORS['accent'], fontsize=9)
    
    # Compatibility Matrix
    create_rounded_box(ax, 10, 25, 35, 15, "Backward Compatibility\n• API Stability\n• Migration Guides\n• Deprecation Notices\n• Support Timeline", 
                      COLORS['success'], fontsize=10)
    
    # Release Process
    create_rounded_box(ax, 55, 25, 35, 15, "Release Process\n• Automated Testing\n• Security Scanning\n• Documentation\n• Registry Publication", 
                      COLORS['primary'], fontsize=10)
    
    # Git Workflow
    create_rounded_box(ax, 20, 5, 60, 10, "Git Workflow Integration\nBranching Strategy • Tag Management • Release Automation • CI/CD Pipeline", 
                      COLORS['dark_blue'], fontsize=11)
    
    plt.tight_layout()
    return fig

def diagram_4_testing_validation():
    """Generate Figure 5.4: Testing and Validation Workflows"""
    fig, ax = setup_diagram(
        title="Testing and Validation Workflows",
        subtitle="Multi-level testing pyramid with automated quality gates"
    )
    
    # Testing Pyramid
    pyramid_levels = [
        ("End-to-End Tests", 40, 75, 20, 8, COLORS['primary']),
        ("Integration Tests", 35, 65, 30, 8, COLORS['accent']),
        ("Unit Tests", 25, 55, 50, 8, COLORS['success'])
    ]
    
    for level, x, y, width, height, color in pyramid_levels:
        create_rounded_box(ax, x, y, width, height, level, color, fontsize=11)
    
    # Test Types Detail
    create_rounded_box(ax, 5, 40, 25, 12, "Unit Testing\n• Variable Validation\n• Logic Testing\n• Syntax Checking\n• Format Validation", 
                      COLORS['success'], fontsize=9)
    
    create_rounded_box(ax, 35, 40, 30, 12, "Integration Testing\n• Module Composition\n• Cross-Module Dependencies\n• Environment Testing\n• Performance Validation", 
                      COLORS['accent'], fontsize=9)
    
    create_rounded_box(ax, 70, 40, 25, 12, "E2E Testing\n• Full Deployment\n• Real Infrastructure\n• Cost Validation\n• Security Compliance", 
                      COLORS['primary'], fontsize=9)
    
    # Quality Gates
    create_rounded_box(ax, 10, 22, 80, 10, "Automated Quality Gates\nSecurity Scanning • Cost Analysis • Performance Testing • Compliance Validation", 
                      COLORS['warning'], COLORS['text'], fontsize=12)
    
    # CI/CD Pipeline
    pipeline_steps = [
        ("Code\nCommit", 10, 8),
        ("Validate", 25, 8),
        ("Test", 40, 8),
        ("Scan", 55, 8),
        ("Release", 70, 8),
        ("Deploy", 85, 8)
    ]
    
    for step, x, y in pipeline_steps:
        create_rounded_box(ax, x-5, y-3, 10, 6, step, COLORS['secondary'], fontsize=9)
    
    # Connect pipeline steps
    for i in range(len(pipeline_steps)-1):
        start_x = pipeline_steps[i][1] + 5
        end_x = pipeline_steps[i+1][1] - 5
        create_arrow(ax, (start_x, 8), (end_x, 8))
    
    # Testing Tools
    ax.text(5, 35, "Testing Tools:", fontsize=12, fontweight='bold', color=COLORS['text'])
    ax.text(5, 32, "• Terratest (Go-based testing)", fontsize=10, color=COLORS['text'])
    ax.text(5, 29, "• TFSec (Security scanning)", fontsize=10, color=COLORS['text'])
    ax.text(5, 26, "• Infracost (Cost analysis)", fontsize=10, color=COLORS['text'])
    
    plt.tight_layout()
    return fig

def diagram_5_enterprise_governance():
    """Generate Figure 5.5: Enterprise Governance and Distribution"""
    fig, ax = setup_diagram(
        title="Enterprise Governance and Distribution",
        subtitle="Module registry, approval workflows, and enterprise integration"
    )
    
    # Governance Framework
    create_rounded_box(ax, 5, 80, 90, 12, "Enterprise Governance Framework\nPolicies • Standards • Compliance • Security • Cost Management", 
                      COLORS['dark_blue'], fontsize=12)
    
    # Approval Workflow
    approval_steps = [
        ("Developer\nSubmission", 10, 65, COLORS['primary']),
        ("Code\nReview", 30, 65, COLORS['accent']),
        ("Security\nScan", 50, 65, COLORS['warning']),
        ("Business\nApproval", 70, 65, COLORS['success']),
        ("Registry\nPublication", 90, 65, COLORS['secondary'])
    ]
    
    for step, x, y, color in approval_steps:
        create_rounded_box(ax, x-7, y-5, 14, 10, step, color, fontsize=9)
    
    # Connect approval steps
    for i in range(len(approval_steps)-1):
        start_x = approval_steps[i][1] + 7
        end_x = approval_steps[i+1][1] - 7
        create_arrow(ax, (start_x, 65), (end_x, 65))
    
    # Module Registry
    create_rounded_box(ax, 15, 45, 70, 12, "Private Module Registry\nVersion Management • Access Control • Usage Analytics • Documentation", 
                      COLORS['light_blue'], COLORS['text'], fontsize=11)
    
    # Distribution Channels
    channels = [
        ("Internal\nRegistry", 10, 30, COLORS['primary']),
        ("Public\nRegistry", 30, 30, COLORS['accent']),
        ("Git\nRepositories", 50, 30, COLORS['success']),
        ("IBM Cloud\nSchematics", 70, 30, COLORS['warning']),
        ("Enterprise\nCatalog", 90, 30, COLORS['secondary'])
    ]
    
    for channel, x, y, color in channels:
        create_rounded_box(ax, x-8, y-5, 16, 10, channel, color, fontsize=9)
    
    # Access Control
    create_rounded_box(ax, 5, 12, 40, 10, "Access Control & Security\nRole-Based Access • API Keys • Audit Logging", 
                      COLORS['accent'], fontsize=10)
    
    # Usage Analytics
    create_rounded_box(ax, 55, 12, 40, 10, "Usage Analytics & Monitoring\nDownload Metrics • Performance Data • Cost Tracking", 
                      COLORS['success'], fontsize=10)
    
    # Integration arrows
    create_arrow(ax, (50, 45), (50, 35))
    create_arrow(ax, (25, 30), (25, 22))
    create_arrow(ax, (75, 30), (75, 22))
    
    plt.tight_layout()
    return fig

def generate_all_diagrams():
    """Generate all 5 diagrams and save them"""
    # Create output directory
    output_dir = "generated_diagrams"
    os.makedirs(output_dir, exist_ok=True)
    
    diagrams = [
        (diagram_1_module_architecture, "01_module_architecture_composition.png"),
        (diagram_2_interface_design, "02_module_interface_dataflow.png"),
        (diagram_3_versioning_lifecycle, "03_versioning_lifecycle_management.png"),
        (diagram_4_testing_validation, "04_testing_validation_workflows.png"),
        (diagram_5_enterprise_governance, "05_enterprise_governance_distribution.png")
    ]
    
    print("🎨 Generating Module Creation Diagrams...")
    print("=" * 50)
    
    total_size = 0
    
    for diagram_func, filename in diagrams:
        print(f"📊 Creating {filename}...")
        
        try:
            fig = diagram_func()
            filepath = os.path.join(output_dir, filename)
            fig.savefig(filepath, dpi=300, bbox_inches='tight', 
                       facecolor=COLORS['background'], edgecolor='none')
            plt.close(fig)
            
            # Get file size
            size = os.path.getsize(filepath)
            total_size += size
            print(f"   ✅ Saved: {filepath} ({size/1024:.1f} KB)")
            
        except Exception as e:
            print(f"   ❌ Error creating {filename}: {str(e)}")
    
    print("=" * 50)
    print(f"🎉 Successfully generated 5 diagrams!")
    print(f"📁 Total size: {total_size/1024/1024:.2f} MB")
    print(f"📍 Location: {os.path.abspath(output_dir)}")
    print(f"🕒 Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

if __name__ == "__main__":
    generate_all_diagrams()
