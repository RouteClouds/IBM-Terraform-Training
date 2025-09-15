#!/usr/bin/env python3
"""
Core Terraform Commands - Diagram as Code (DaC)
Generates 5 professional diagrams for Terraform command workflow concepts.

Diagrams:
1. terraform_workflow.png - Complete workflow lifecycle overview
2. init_process.png - Detailed initialization process and components
3. plan_analysis.png - Plan generation and analysis workflow
4. apply_process.png - Apply execution and state management
5. destroy_process.png - Destruction workflow and safety procedures

Author: IBM Cloud Terraform Training Program
Created: 2024-01-20
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
import seaborn as sns
from matplotlib.patches import FancyBboxPatch, ConnectionPatch, Circle, Arrow
import os

# Set style and color palette
plt.style.use('default')
sns.set_palette("husl")

# IBM Brand Colors
IBM_BLUE = '#1261FE'
IBM_DARK_BLUE = '#0F62FE'
IBM_LIGHT_BLUE = '#4589FF'
IBM_GRAY = '#525252'
IBM_LIGHT_GRAY = '#F4F4F4'
IBM_WHITE = '#FFFFFF'
IBM_GREEN = '#24A148'
IBM_ORANGE = '#FF832B'
IBM_RED = '#DA1E28'
IBM_PURPLE = '#8A3FFC'

def setup_figure(title, figsize=(16, 12)):
    """Setup figure with IBM branding and professional styling."""
    fig, ax = plt.subplots(figsize=figsize, dpi=300)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Add title with IBM styling
    fig.suptitle(title, fontsize=20, fontweight='bold', color=IBM_BLUE, y=0.95)
    
    # Add IBM Cloud branding
    ax.text(0.02, 0.02, 'IBM Cloud Terraform Training', 
            transform=ax.transAxes, fontsize=10, color=IBM_GRAY,
            bbox=dict(boxstyle="round,pad=0.3", facecolor=IBM_LIGHT_GRAY, alpha=0.8))
    
    return fig, ax

def create_rounded_box(ax, x, y, width, height, text, color=IBM_BLUE, text_color=IBM_WHITE, fontsize=10):
    """Create a rounded rectangle with text."""
    box = FancyBboxPatch((x, y), width, height,
                         boxstyle="round,pad=0.02",
                         facecolor=color, edgecolor=IBM_GRAY, linewidth=1.5)
    ax.add_patch(box)
    
    # Add text
    ax.text(x + width/2, y + height/2, text, ha='center', va='center',
            fontsize=fontsize, color=text_color, weight='bold', wrap=True)

def create_arrow(ax, start, end, color=IBM_GRAY, style='->'):
    """Create an arrow between two points."""
    arrow = ConnectionPatch(start, end, "data", "data",
                           arrowstyle=style, shrinkA=5, shrinkB=5,
                           mutation_scale=20, fc=color, ec=color, linewidth=2)
    ax.add_patch(arrow)

def create_command_box(ax, x, y, width, height, command, description, color):
    """Create a command box with command name and description."""
    # Main command box
    create_rounded_box(ax, x, y, width, height, f"{command}\n\n{description}", color, IBM_WHITE, 10)
    
    # Command name highlight
    cmd_box = FancyBboxPatch((x + 0.1, y + height - 0.4), width - 0.2, 0.3,
                            boxstyle="round,pad=0.02",
                            facecolor=IBM_WHITE, edgecolor=color, linewidth=2)
    ax.add_patch(cmd_box)
    ax.text(x + width/2, y + height - 0.25, command, ha='center', va='center',
            fontsize=12, color=color, weight='bold')

def diagram_1_terraform_workflow():
    """Generate complete workflow lifecycle overview diagram."""
    fig, ax = setup_figure("Terraform Workflow Lifecycle - Complete Command Sequence")
    
    # Workflow title
    create_rounded_box(ax, 1, 8.5, 8, 1, 
                      "Complete Terraform Workflow - From Initialization to Cleanup", 
                      IBM_BLUE, IBM_WHITE, 14)
    
    # Command sequence
    commands = [
        ("terraform init", "Initialize\nProviders & Backend", IBM_GREEN, 0.5),
        ("terraform validate", "Validate\nConfiguration", IBM_ORANGE, 2.5),
        ("terraform plan", "Generate\nExecution Plan", IBM_PURPLE, 4.5),
        ("terraform apply", "Deploy\nInfrastructure", IBM_BLUE, 6.5),
        ("terraform destroy", "Cleanup\nResources", IBM_RED, 8.5)
    ]
    
    y_pos = 6.5
    for i, (cmd, desc, color, x_pos) in enumerate(commands):
        create_command_box(ax, x_pos, y_pos, 1.8, 1.5, cmd, desc, color)
        
        # Add arrows between commands
        if i < len(commands) - 1:
            create_arrow(ax, (x_pos + 1.8, y_pos + 0.75), (commands[i+1][3], y_pos + 0.75), color)
    
    # Workflow phases
    create_rounded_box(ax, 0.5, 4.5, 4.5, 1.5, 
                      "Development Phase\n\n• Frequent init, validate, plan cycles\n• Iterative development and testing\n• Local state management", 
                      IBM_LIGHT_BLUE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 5.2, 4.5, 4.3, 1.5, 
                      "Production Phase\n\n• Plan-based deployments\n• Change approval workflows\n• Remote state management", 
                      IBM_DARK_BLUE, IBM_WHITE, 9)
    
    # Best practices
    create_rounded_box(ax, 1, 2.5, 8, 1.5, 
                      "Enterprise Best Practices\n\nAlways validate before planning • Save plans for approval • Use automation scripts\nImplement proper error handling • Monitor command execution • Maintain audit logs", 
                      IBM_LIGHT_GRAY, IBM_GRAY, 10)
    
    # Success metrics
    create_rounded_box(ax, 2, 0.5, 6, 1.5, 
                      "Workflow Benefits\n\n85% fewer deployment errors • 70% faster provisioning • 90% better change management\n60% fewer rollbacks • 95% improved compliance", 
                      IBM_GREEN, IBM_WHITE, 10)
    
    plt.tight_layout()
    plt.savefig('generated_diagrams/terraform_workflow.png', dpi=300, bbox_inches='tight')
    plt.close()

def diagram_2_init_process():
    """Generate detailed initialization process diagram."""
    fig, ax = setup_figure("Terraform Init Process - Provider Downloads and Backend Configuration")
    
    # Process title
    create_rounded_box(ax, 1, 8.5, 8, 1, 
                      "terraform init - Initialization Process and Components", 
                      IBM_GREEN, IBM_WHITE, 14)
    
    # Init command
    create_rounded_box(ax, 4, 7, 2, 1, "terraform init", IBM_GREEN, IBM_WHITE, 12)
    
    # Process steps
    steps = [
        ("Read Configuration", "Parse .tf files\nIdentify providers", IBM_BLUE, 0.5, 5.5),
        ("Download Providers", "Fetch from registry\nVerify signatures", IBM_ORANGE, 3, 5.5),
        ("Initialize Backend", "Configure state storage\nSet up locking", IBM_PURPLE, 5.5, 5.5),
        ("Install Modules", "Download modules\nResolve dependencies", IBM_DARK_BLUE, 8, 5.5)
    ]
    
    for title, desc, color, x, y in steps:
        create_rounded_box(ax, x, y, 1.8, 1.2, f"{title}\n\n{desc}", color, IBM_WHITE, 9)
        create_arrow(ax, (5, 7), (x + 0.9, y + 1.2), IBM_GRAY)
    
    # Generated artifacts
    create_rounded_box(ax, 0.5, 3.5, 2, 1.5, 
                      ".terraform/\nDirectory\n\n• Providers\n• Modules\n• Plugins", 
                      IBM_LIGHT_BLUE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 3, 3.5, 2, 1.5, 
                      ".terraform.lock.hcl\nLock File\n\n• Provider versions\n• Checksums\n• Dependencies", 
                      IBM_LIGHT_BLUE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 5.5, 3.5, 2, 1.5, 
                      "Backend Config\nState Storage\n\n• Local/Remote\n• Locking\n• Encryption", 
                      IBM_LIGHT_BLUE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 8, 3.5, 1.5, 1.5, 
                      "Workspace\nSetup\n\n• Default\n• Named\n• Isolation", 
                      IBM_LIGHT_BLUE, IBM_WHITE, 9)
    
    # Common flags
    create_rounded_box(ax, 1, 1.5, 8, 1.5, 
                      "Common Init Flags\n\n-upgrade (update providers) • -reconfigure (reset backend) • -migrate-state (move state)\n-no-color (CI/CD) • -input=false (automation) • -plugin-dir (custom location)", 
                      IBM_LIGHT_GRAY, IBM_GRAY, 10)
    
    # Troubleshooting
    create_rounded_box(ax, 2.5, 0.2, 5, 1, 
                      "Troubleshooting: Network issues • Proxy configuration • Provider availability • Backend permissions", 
                      IBM_ORANGE, IBM_WHITE, 9)
    
    plt.tight_layout()
    plt.savefig('generated_diagrams/init_process.png', dpi=300, bbox_inches='tight')
    plt.close()

def diagram_3_plan_analysis():
    """Generate plan generation and analysis workflow diagram."""
    fig, ax = setup_figure("Terraform Plan Analysis - Change Detection and Impact Assessment")
    
    # Plan command
    create_rounded_box(ax, 4, 8.5, 2, 1, "terraform plan", IBM_PURPLE, IBM_WHITE, 12)
    
    # Analysis process
    create_rounded_box(ax, 0.5, 7, 2, 1.2, 
                      "Current State\nAnalysis\n\n• Read .tfstate\n• Resource status\n• Dependencies", 
                      IBM_BLUE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 3, 7, 2, 1.2, 
                      "Desired State\nParsing\n\n• Configuration files\n• Variable values\n• Resource definitions", 
                      IBM_GREEN, IBM_WHITE, 9)
    
    create_rounded_box(ax, 5.5, 7, 2, 1.2, 
                      "Change Detection\nEngine\n\n• Compare states\n• Identify diffs\n• Plan actions", 
                      IBM_ORANGE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 8, 7, 1.5, 1.2, 
                      "Dependency\nResolution\n\n• Order actions\n• Handle refs\n• Validate", 
                      IBM_PURPLE, IBM_WHITE, 9)
    
    # Arrows from plan command
    create_arrow(ax, (4.5, 8.5), (1.5, 8.2), IBM_GRAY)
    create_arrow(ax, (5, 8.5), (4, 8.2), IBM_GRAY)
    create_arrow(ax, (5.5, 8.5), (6.5, 8.2), IBM_GRAY)
    create_arrow(ax, (5.5, 8.5), (8.7, 8.2), IBM_GRAY)
    
    # Plan output symbols
    create_rounded_box(ax, 0.5, 5, 9, 1.5, 
                      "Plan Output Symbols\n\n+ CREATE (new resource) • ~ UPDATE (modify existing) • - DESTROY (remove resource)\n-/+ REPLACE (destroy and recreate) • <= READ (data source)", 
                      IBM_LIGHT_GRAY, IBM_GRAY, 11)
    
    # Plan types
    create_rounded_box(ax, 0.5, 3, 3, 1.5, 
                      "Standard Plan\n\n• Show all changes\n• Resource details\n• Dependency order\n• Impact assessment", 
                      IBM_LIGHT_BLUE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 3.8, 3, 3, 1.5, 
                      "Targeted Plan\n\n• Specific resources\n• -target flag\n• Subset planning\n• Focused changes", 
                      IBM_DARK_BLUE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 7.1, 3, 2.4, 1.5, 
                      "Destroy Plan\n\n• -destroy flag\n• Reverse order\n• Safety checks\n• Impact review", 
                      IBM_RED, IBM_WHITE, 9)
    
    # Advanced features
    create_rounded_box(ax, 1, 1, 8, 1.5, 
                      "Advanced Planning Features\n\n-out (save plan) • -json (automation) • -detailed-exitcode (CI/CD)\n-refresh=false (performance) • -var (overrides) • -parallelism (concurrency)", 
                      IBM_LIGHT_GRAY, IBM_GRAY, 10)
    
    plt.tight_layout()
    plt.savefig('generated_diagrams/plan_analysis.png', dpi=300, bbox_inches='tight')
    plt.close()

def diagram_4_apply_process():
    """Generate apply execution and state management diagram."""
    fig, ax = setup_figure("Terraform Apply Process - Resource Provisioning and State Management")
    
    # Apply command
    create_rounded_box(ax, 4, 8.5, 2, 1, "terraform apply", IBM_BLUE, IBM_WHITE, 12)
    
    # Execution phases
    phases = [
        ("Plan Validation", "Verify saved plan\nCheck consistency", IBM_GREEN, 0.5, 7),
        ("Resource Creation", "Provision resources\nHandle dependencies", IBM_BLUE, 2.5, 7),
        ("State Updates", "Update .tfstate\nRecord changes", IBM_ORANGE, 4.5, 7),
        ("Output Generation", "Display results\nShow outputs", IBM_PURPLE, 6.5, 7),
        ("Cleanup", "Remove temp files\nFinalize state", IBM_DARK_BLUE, 8.5, 7)
    ]
    
    for i, (title, desc, color, x, y) in enumerate(phases):
        create_rounded_box(ax, x, y, 1.8, 1.2, f"{title}\n\n{desc}", color, IBM_WHITE, 9)
        
        # Connect to apply command
        create_arrow(ax, (5, 8.5), (x + 0.9, y + 1.2), IBM_GRAY)
        
        # Connect phases in sequence
        if i < len(phases) - 1:
            create_arrow(ax, (x + 1.8, y + 0.6), (phases[i+1][3], y + 0.6), IBM_GRAY)
    
    # Apply modes
    create_rounded_box(ax, 0.5, 5, 3, 1.5, 
                      "Interactive Apply\n\n• Manual confirmation\n• Review changes\n• Safety prompts\n• Development use", 
                      IBM_LIGHT_BLUE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 3.8, 5, 3, 1.5, 
                      "Plan-based Apply\n\n• Pre-approved plan\n• No confirmation\n• Production ready\n• Audit trail", 
                      IBM_GREEN, IBM_WHITE, 9)
    
    create_rounded_box(ax, 7.1, 5, 2.4, 1.5, 
                      "Auto-approve\n\n• -auto-approve\n• Automation\n• CI/CD pipelines\n• Use with caution", 
                      IBM_ORANGE, IBM_WHITE, 9)
    
    # Error handling
    create_rounded_box(ax, 0.5, 3, 4.5, 1.5, 
                      "Error Handling and Recovery\n\n• Partial apply failures • State corruption protection\n• Rollback procedures • Resource drift detection\n• Retry mechanisms • Dependency resolution", 
                      IBM_RED, IBM_WHITE, 9)
    
    create_rounded_box(ax, 5.2, 3, 4.3, 1.5, 
                      "Performance Optimization\n\n• Parallelism control • Resource batching\n• Provider optimization • Network efficiency\n• State locking • Concurrent execution", 
                      IBM_DARK_BLUE, IBM_WHITE, 9)
    
    # Monitoring and logging
    create_rounded_box(ax, 1.5, 1, 7, 1.5, 
                      "Monitoring and Logging\n\nTF_LOG environment variable • Progress tracking • Resource timing\nError diagnostics • State change logging • Audit compliance", 
                      IBM_LIGHT_GRAY, IBM_GRAY, 10)
    
    plt.tight_layout()
    plt.savefig('generated_diagrams/apply_process.png', dpi=300, bbox_inches='tight')
    plt.close()

def diagram_5_destroy_process():
    """Generate destruction workflow and safety procedures diagram."""
    fig, ax = setup_figure("Terraform Destroy Process - Safe Resource Cleanup and Validation")
    
    # Destroy command
    create_rounded_box(ax, 4, 8.5, 2, 1, "terraform destroy", IBM_RED, IBM_WHITE, 12)
    
    # Safety workflow
    create_rounded_box(ax, 0.5, 7, 2, 1.2, 
                      "Pre-destroy\nValidation\n\n• State backup\n• Resource review\n• Dependencies", 
                      IBM_ORANGE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 3, 7, 2, 1.2, 
                      "Destruction\nPlanning\n\n• Reverse order\n• Dependency graph\n• Impact analysis", 
                      IBM_PURPLE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 5.5, 7, 2, 1.2, 
                      "Resource\nDeletion\n\n• API calls\n• Error handling\n• Progress tracking", 
                      IBM_RED, IBM_WHITE, 9)
    
    create_rounded_box(ax, 8, 7, 1.5, 1.2, 
                      "State\nCleanup\n\n• Remove entries\n• Update file\n• Verification", 
                      IBM_BLUE, IBM_WHITE, 9)
    
    # Connect workflow
    create_arrow(ax, (5, 8.5), (1.5, 8.2), IBM_GRAY)
    create_arrow(ax, (2.5, 7.6), (3, 7.6), IBM_GRAY)
    create_arrow(ax, (5, 7.6), (5.5, 7.6), IBM_GRAY)
    create_arrow(ax, (7.5, 7.6), (8, 7.6), IBM_GRAY)
    
    # Destroy strategies
    create_rounded_box(ax, 0.5, 5, 3, 1.5, 
                      "Complete Destroy\n\n• All resources\n• Full cleanup\n• Environment teardown\n• Cost optimization", 
                      IBM_RED, IBM_WHITE, 9)
    
    create_rounded_box(ax, 3.8, 5, 3, 1.5, 
                      "Targeted Destroy\n\n• Specific resources\n• -target flag\n• Selective cleanup\n• Partial teardown", 
                      IBM_ORANGE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 7.1, 5, 2.4, 1.5, 
                      "Planned Destroy\n\n• -destroy plan\n• Review process\n• Approval workflow\n• Audit trail", 
                      IBM_PURPLE, IBM_WHITE, 9)
    
    # Safety measures
    create_rounded_box(ax, 0.5, 3, 4.5, 1.5, 
                      "Safety and Recovery Measures\n\n• State backups before destruction • Resource export\n• Confirmation prompts • Dependency validation\n• Rollback procedures • Recovery planning", 
                      IBM_LIGHT_BLUE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 5.2, 3, 4.3, 1.5, 
                      "Enterprise Destroy Patterns\n\n• Scheduled cleanup • Environment lifecycle\n• Cost optimization • Security compliance\n• Automated workflows • Approval gates", 
                      IBM_DARK_BLUE, IBM_WHITE, 9)
    
    # Best practices
    create_rounded_box(ax, 1.5, 1, 7, 1.5, 
                      "Destruction Best Practices\n\nAlways plan before destroy • Backup critical data • Review dependencies\nUse targeted destruction • Monitor progress • Verify cleanup completion", 
                      IBM_LIGHT_GRAY, IBM_GRAY, 10)
    
    plt.tight_layout()
    plt.savefig('generated_diagrams/destroy_process.png', dpi=300, bbox_inches='tight')
    plt.close()

def main():
    """Generate all diagrams for core Terraform commands."""
    # Create output directory if it doesn't exist
    os.makedirs('generated_diagrams', exist_ok=True)
    
    print("Generating Core Terraform Commands diagrams...")
    
    # Generate all diagrams
    diagram_1_terraform_workflow()
    print("✅ Generated: terraform_workflow.png")
    
    diagram_2_init_process()
    print("✅ Generated: init_process.png")
    
    diagram_3_plan_analysis()
    print("✅ Generated: plan_analysis.png")
    
    diagram_4_apply_process()
    print("✅ Generated: apply_process.png")
    
    diagram_5_destroy_process()
    print("✅ Generated: destroy_process.png")
    
    print("\n🎉 All diagrams generated successfully!")
    print("📁 Output directory: generated_diagrams/")
    print("📊 Resolution: 300 DPI for professional quality")
    print("🎨 Style: IBM Cloud branding with command-focused design")

if __name__ == "__main__":
    main()
