#!/usr/bin/env python3
"""
Terraform CLI Installation - Diagram as Code Implementation
This script generates visual diagrams to illustrate Terraform CLI installation concepts and processes.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, Rectangle, Circle, ConnectionPatch
import numpy as np
import pandas as pd
import seaborn as sns
from PIL import Image, ImageDraw, ImageFont
import os

# Set professional styling
plt.style.use('seaborn-v0_8-whitegrid')
sns.set_palette("husl")

# Professional color scheme
COLORS = {
    'primary': '#1f70c1',      # IBM Blue
    'secondary': '#0f62fe',    # IBM Blue 60
    'accent': '#ff6b6b',       # Coral Red
    'success': '#4caf50',      # Green
    'warning': '#ff9800',      # Orange
    'info': '#2196f3',         # Light Blue
    'light': '#f8f9fa',        # Light Gray
    'dark': '#343a40',         # Dark Gray
    'white': '#ffffff',        # White
    'gradient_start': '#667eea', # Gradient Blue
    'gradient_end': '#764ba2'    # Gradient Purple
}

# Professional fonts and sizing
FONT_SIZES = {
    'title': 16,
    'subtitle': 14,
    'heading': 12,
    'body': 10,
    'caption': 8,
    'small': 7
}

# Set up the output directory
output_dir = "generated_diagrams"
os.makedirs(output_dir, exist_ok=True)

def create_professional_figure(figsize=(16, 10), title="", subtitle=""):
    """Create a professionally styled figure with consistent formatting"""
    fig, ax = plt.subplots(figsize=figsize, facecolor='white')

    # Set professional styling
    ax.set_facecolor('#fafbfc')
    ax.grid(True, alpha=0.3, linestyle='-', linewidth=0.5)
    ax.set_axisbelow(True)

    # Add title with professional styling
    if title:
        fig.suptitle(title, fontsize=FONT_SIZES['title'], fontweight='bold',
                    color=COLORS['dark'], y=0.95)

    if subtitle:
        ax.text(0.5, 0.92, subtitle, transform=fig.transFigure,
                fontsize=FONT_SIZES['subtitle'], ha='center',
                color=COLORS['primary'], style='italic')

    return fig, ax

def create_gradient_box(ax, pos, size, start_color, end_color, alpha=0.8):
    """Create a gradient-filled box for professional appearance"""
    x, y = pos
    width, height = size

    # Create gradient effect using multiple rectangles
    n_steps = 20
    for i in range(n_steps):
        # Interpolate between colors
        ratio = i / (n_steps - 1)
        r = int(int(start_color[1:3], 16) * (1 - ratio) + int(end_color[1:3], 16) * ratio)
        g = int(int(start_color[3:5], 16) * (1 - ratio) + int(end_color[3:5], 16) * ratio)
        b = int(int(start_color[5:7], 16) * (1 - ratio) + int(end_color[5:7], 16) * ratio)
        color = f'#{r:02x}{g:02x}{b:02x}'

        rect = Rectangle((x, y + i * height / n_steps), width, height / n_steps,
                        facecolor=color, alpha=alpha, edgecolor='none')
        ax.add_patch(rect)

def add_professional_legend(ax, items, position='upper right'):
    """Add a professionally styled legend"""
    legend_elements = []
    for item in items:
        legend_elements.append(plt.Line2D([0], [0], marker='o', color='w',
                                        markerfacecolor=item['color'],
                                        markersize=10, label=item['label']))

    legend = ax.legend(handles=legend_elements, loc=position,
                      frameon=True, fancybox=True, shadow=True,
                      fontsize=FONT_SIZES['body'])
    legend.get_frame().set_facecolor('white')
    legend.get_frame().set_alpha(0.9)

def create_professional_arrow(ax, start, end, style='->', color=COLORS['primary'],
                            linewidth=2, alpha=0.8):
    """Create a professional arrow with consistent styling"""
    ax.annotate('', xy=end, xytext=start,
                arrowprops=dict(arrowstyle=style, lw=linewidth,
                              color=color, alpha=alpha,
                              connectionstyle="arc3,rad=0.1"))

def add_watermark(ax, text="IBM Cloud Terraform Training"):
    """Add a subtle watermark to the diagram"""
    ax.text(0.99, 0.01, text, transform=ax.transAxes,
            fontsize=FONT_SIZES['caption'], alpha=0.3,
            ha='right', va='bottom', color=COLORS['dark'],
            style='italic')

def create_installation_methods_diagram():
    """Create a professionally styled diagram showing different Terraform CLI installation methods"""
    fig, ax = create_professional_figure(
        figsize=(18, 12),
        title='Terraform CLI Installation Methods by Operating System',
        subtitle='Comprehensive guide to platform-specific installation approaches'
    )
    ax.set_xlim(0, 18)
    ax.set_ylim(0, 12)
    ax.axis('off')
    
    # Operating system sections with professional styling
    os_sections = [
        {
            'name': 'Windows', 'x': 4, 'color': COLORS['primary'],
            'gradient_end': '#0056b3', 'icon': '🪟',
            'methods': [
                {'name': 'Manual Binary', 'recommended': False, 'difficulty': 'Medium'},
                {'name': 'Chocolatey', 'recommended': True, 'difficulty': 'Easy'},
                {'name': 'Winget', 'recommended': True, 'difficulty': 'Easy'},
                {'name': 'Docker', 'recommended': False, 'difficulty': 'Advanced'}
            ]
        },
        {
            'name': 'macOS', 'x': 9, 'color': COLORS['success'],
            'gradient_end': '#2e7d32', 'icon': '🍎',
            'methods': [
                {'name': 'Homebrew', 'recommended': True, 'difficulty': 'Easy'},
                {'name': 'Manual Binary', 'recommended': False, 'difficulty': 'Medium'},
                {'name': 'MacPorts', 'recommended': False, 'difficulty': 'Medium'},
                {'name': 'Docker', 'recommended': False, 'difficulty': 'Advanced'}
            ]
        },
        {
            'name': 'Linux', 'x': 14, 'color': COLORS['warning'],
            'gradient_end': '#e65100', 'icon': '🐧',
            'methods': [
                {'name': 'Package Manager', 'recommended': True, 'difficulty': 'Easy'},
                {'name': 'Manual Binary', 'recommended': False, 'difficulty': 'Medium'},
                {'name': 'Snap', 'recommended': False, 'difficulty': 'Easy'},
                {'name': 'Docker', 'recommended': False, 'difficulty': 'Advanced'}
            ]
        }
    ]
    
    for os_info in os_sections:
        # OS header with gradient effect
        create_gradient_box(ax, (os_info['x'] - 1.8, 9), (3.6, 1.8),
                           os_info['color'], os_info['gradient_end'], alpha=0.9)

        # OS header border
        header_rect = FancyBboxPatch((os_info['x'] - 1.8, 9), 3.6, 1.8,
                                   boxstyle="round,pad=0.1",
                                   facecolor='none', edgecolor=COLORS['dark'],
                                   linewidth=2.5)
        ax.add_patch(header_rect)

        # OS icon and name
        ax.text(os_info['x'], 10.2, os_info['icon'], ha='center', va='center',
                fontsize=24)
        ax.text(os_info['x'], 9.5, os_info['name'], ha='center', va='center',
                fontsize=FONT_SIZES['subtitle'], fontweight='bold', color='white')

        # Installation methods with professional styling
        for i, method in enumerate(os_info['methods']):
            y_pos = 7.8 - (i * 1.3)

            # Method background with difficulty-based coloring
            if method['difficulty'] == 'Easy':
                method_color = COLORS['success']
                method_alpha = 0.8
            elif method['difficulty'] == 'Medium':
                method_color = COLORS['warning']
                method_alpha = 0.7
            else:  # Advanced
                method_color = COLORS['accent']
                method_alpha = 0.6

            method_rect = FancyBboxPatch((os_info['x'] - 1.6, y_pos - 0.45), 3.2, 0.9,
                                       boxstyle="round,pad=0.08",
                                       facecolor=method_color, alpha=method_alpha,
                                       edgecolor=COLORS['dark'], linewidth=1.5)
            ax.add_patch(method_rect)

            # Method name
            ax.text(os_info['x'] - 0.8, y_pos, method['name'], ha='left', va='center',
                    fontsize=FONT_SIZES['body'], fontweight='bold', color='white')

            # Difficulty indicator
            ax.text(os_info['x'] + 1.3, y_pos + 0.2, method['difficulty'],
                    ha='center', va='center', fontsize=FONT_SIZES['caption'],
                    color='white', style='italic')

            # Recommendation indicators with enhanced styling
            if method['recommended']:
                # Gold star for recommended methods
                ax.text(os_info['x'] + 1.3, y_pos - 0.2, '⭐', ha='center', va='center',
                        fontsize=14, color='gold')
                # "RECOMMENDED" badge
                badge_rect = FancyBboxPatch((os_info['x'] - 1.5, y_pos - 0.4), 0.8, 0.3,
                                          boxstyle="round,pad=0.02",
                                          facecolor='gold', alpha=0.9,
                                          edgecolor=COLORS['dark'], linewidth=1)
                ax.add_patch(badge_rect)
                ax.text(os_info['x'] - 1.1, y_pos - 0.25, 'REC', ha='center', va='center',
                        fontsize=FONT_SIZES['small'], fontweight='bold', color=COLORS['dark'])
    
    # Professional legend with multiple indicators
    legend_items = [
        {'color': COLORS['success'], 'label': 'Easy Installation'},
        {'color': COLORS['warning'], 'label': 'Medium Complexity'},
        {'color': COLORS['accent'], 'label': 'Advanced Setup'}
    ]
    add_professional_legend(ax, legend_items, position='lower center')

    # Enhanced information panel
    info_rect = FancyBboxPatch((1, 1), 16, 1.5, boxstyle="round,pad=0.15",
                              facecolor=COLORS['light'], alpha=0.95,
                              edgecolor=COLORS['primary'], linewidth=2)
    ax.add_patch(info_rect)

    # Legend text with professional formatting
    legend_text = "⭐ = Recommended Method  |  🏆 = Best Practice  |  💡 = Enterprise Ready"
    ax.text(9, 1.75, legend_text, ha='center', va='center',
            fontsize=FONT_SIZES['body'], fontweight='bold', color=COLORS['dark'])

    # Additional guidance
    guidance_text = "Choose installation method based on your platform, experience level, and organizational requirements"
    ax.text(9, 1.25, guidance_text, ha='center', va='center',
            fontsize=FONT_SIZES['caption'], style='italic', color=COLORS['primary'])

    # Add watermark
    add_watermark(ax)

    plt.tight_layout()
    plt.savefig(f'{output_dir}/installation_methods.png', dpi=300, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    plt.close()

def create_terraform_architecture_diagram():
    """Create a diagram showing Terraform CLI architecture and components"""
    fig, ax = plt.subplots(figsize=(14, 10))
    ax.set_title('Terraform CLI Architecture and Components', 
                 fontsize=16, fontweight='bold')
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Core Terraform CLI
    core_rect = FancyBboxPatch((5, 7), 4, 1.5, boxstyle="round,pad=0.2", 
                              facecolor='#1f70c1', alpha=0.9,
                              edgecolor='black', linewidth=3)
    ax.add_patch(core_rect)
    ax.text(7, 7.75, 'Terraform CLI', ha='center', va='center', 
            fontsize=14, fontweight='bold', color='white')
    
    # CLI Commands
    commands = [
        {'name': 'init', 'pos': (2, 5.5), 'desc': 'Initialize\nWorkspace'},
        {'name': 'plan', 'pos': (5, 5.5), 'desc': 'Create\nExecution Plan'},
        {'name': 'apply', 'pos': (9, 5.5), 'desc': 'Apply\nChanges'},
        {'name': 'destroy', 'pos': (12, 5.5), 'desc': 'Destroy\nResources'}
    ]
    
    for cmd in commands:
        cmd_rect = FancyBboxPatch((cmd['pos'][0] - 0.8, cmd['pos'][1] - 0.6), 1.6, 1.2, 
                                 boxstyle="round,pad=0.1", 
                                 facecolor='lightgreen', alpha=0.8,
                                 edgecolor='darkgreen', linewidth=2)
        ax.add_patch(cmd_rect)
        ax.text(cmd['pos'][0], cmd['pos'][1] + 0.2, cmd['name'], 
                ha='center', va='center', fontsize=11, fontweight='bold')
        ax.text(cmd['pos'][0], cmd['pos'][1] - 0.3, cmd['desc'], 
                ha='center', va='center', fontsize=9)
        
        # Connection to core
        ax.plot([cmd['pos'][0], 7], [cmd['pos'][1] + 0.6, 7], 
                'gray', linewidth=2, alpha=0.6)
    
    # Provider Plugins
    providers = [
        {'name': 'IBM Cloud\nProvider', 'pos': (2, 3), 'color': '#1f70c1'},
        {'name': 'AWS\nProvider', 'pos': (5, 3), 'color': '#ff9900'},
        {'name': 'Azure\nProvider', 'pos': (9, 3), 'color': '#0078d4'},
        {'name': 'GCP\nProvider', 'pos': (12, 3), 'color': '#4285f4'}
    ]
    
    for provider in providers:
        provider_rect = FancyBboxPatch((provider['pos'][0] - 0.8, provider['pos'][1] - 0.5), 
                                     1.6, 1, boxstyle="round,pad=0.1", 
                                     facecolor=provider['color'], alpha=0.7,
                                     edgecolor='black', linewidth=1)
        ax.add_patch(provider_rect)
        ax.text(provider['pos'][0], provider['pos'][1], provider['name'], 
                ha='center', va='center', fontsize=9, fontweight='bold', color='white')
    
    # Configuration Files
    config_rect = FancyBboxPatch((1, 0.5), 5, 1, boxstyle="round,pad=0.1", 
                                facecolor='lightyellow', alpha=0.8,
                                edgecolor='orange', linewidth=2)
    ax.add_patch(config_rect)
    ax.text(3.5, 1, 'Configuration Files\n(.tf, .tfvars)', 
            ha='center', va='center', fontsize=10, fontweight='bold')
    
    # State Files
    state_rect = FancyBboxPatch((8, 0.5), 5, 1, boxstyle="round,pad=0.1", 
                               facecolor='lightcoral', alpha=0.8,
                               edgecolor='darkred', linewidth=2)
    ax.add_patch(state_rect)
    ax.text(10.5, 1, 'State Files\n(terraform.tfstate)', 
            ha='center', va='center', fontsize=10, fontweight='bold')
    
    # Arrows showing data flow
    ax.annotate('', xy=(7, 6.8), xytext=(3.5, 1.5),
                arrowprops=dict(arrowstyle='->', lw=2, color='blue'))
    ax.annotate('', xy=(10.5, 1.5), xytext=(7, 6.8),
                arrowprops=dict(arrowstyle='->', lw=2, color='red'))
    
    plt.tight_layout()
    plt.savefig(f'{output_dir}/terraform_architecture.png', dpi=300, bbox_inches='tight')
    plt.close()

def create_installation_workflow_diagram():
    """Create a step-by-step installation workflow diagram"""
    fig, ax = plt.subplots(figsize=(16, 8))
    ax.set_title('Terraform CLI Installation Workflow', 
                 fontsize=16, fontweight='bold')
    ax.set_xlim(0, 16)
    ax.set_ylim(0, 8)
    ax.axis('off')
    
    # Workflow steps
    steps = [
        {'step': 1, 'title': 'Download\nTerraform', 'pos': (2, 6), 'color': '#ff6b6b'},
        {'step': 2, 'title': 'Extract\nBinary', 'pos': (5, 6), 'color': '#4ecdc4'},
        {'step': 3, 'title': 'Install to\nPATH', 'pos': (8, 6), 'color': '#45b7d1'},
        {'step': 4, 'title': 'Verify\nInstallation', 'pos': (11, 6), 'color': '#96ceb4'},
        {'step': 5, 'title': 'Configure\nCLI', 'pos': (14, 6), 'color': '#feca57'},
        {'step': 6, 'title': 'Set Environment\nVariables', 'pos': (2, 3), 'color': '#ff9ff3'},
        {'step': 7, 'title': 'Test with\nProvider', 'pos': (5, 3), 'color': '#54a0ff'},
        {'step': 8, 'title': 'Setup Version\nManagement', 'pos': (8, 3), 'color': '#5f27cd'},
        {'step': 9, 'title': 'Create Test\nProject', 'pos': (11, 3), 'color': '#00d2d3'},
        {'step': 10, 'title': 'Validate\nSetup', 'pos': (14, 3), 'color': '#ff6348'}
    ]
    
    for i, step in enumerate(steps):
        # Step circle
        circle = Circle(step['pos'], 0.8, color=step['color'], alpha=0.8)
        ax.add_patch(circle)
        
        # Step number
        ax.text(step['pos'][0], step['pos'][1] + 0.2, str(step['step']), 
                ha='center', va='center', fontsize=14, fontweight='bold', color='white')
        
        # Step title
        ax.text(step['pos'][0], step['pos'][1] - 0.3, step['title'], 
                ha='center', va='center', fontsize=9, fontweight='bold', color='white')
        
        # Arrows between steps
        if i < len(steps) - 1:
            next_step = steps[i + 1]
            if step['pos'][1] == next_step['pos'][1]:  # Same row
                ax.annotate('', xy=(next_step['pos'][0] - 0.8, next_step['pos'][1]), 
                           xytext=(step['pos'][0] + 0.8, step['pos'][1]),
                           arrowprops=dict(arrowstyle='->', lw=2, color='black'))
            elif i == 4:  # From step 5 to step 6 (row change)
                ax.annotate('', xy=(steps[5]['pos'][0], steps[5]['pos'][1] + 0.8), 
                           xytext=(step['pos'][0], step['pos'][1] - 0.8),
                           arrowprops=dict(arrowstyle='->', lw=2, color='black',
                                         connectionstyle="arc3,rad=0.3"))
    
    # Add time estimates
    ax.text(8, 1, 'Estimated Total Time: 30-60 minutes (depending on method and experience)', 
            ha='center', va='center', fontsize=12, fontweight='bold',
            bbox=dict(boxstyle="round,pad=0.3", facecolor='lightyellow'))
    
    plt.tight_layout()
    plt.savefig(f'{output_dir}/installation_workflow.png', dpi=300, bbox_inches='tight')
    plt.close()

def create_version_management_diagram():
    """Create a diagram showing Terraform version management strategies"""
    fig, ax = plt.subplots(figsize=(14, 10))
    ax.set_title('Terraform Version Management Strategies', 
                 fontsize=16, fontweight='bold')
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Version management tools
    tools = [
        {
            'name': 'tfenv', 'pos': (3, 8), 'platforms': ['macOS', 'Linux'],
            'features': ['Multiple versions', 'Easy switching', 'Project-specific'],
            'color': '#2ecc71'
        },
        {
            'name': 'Manual Management', 'pos': (7, 8), 'platforms': ['Windows', 'All'],
            'features': ['Full control', 'Custom paths', 'Script-based'],
            'color': '#3498db'
        },
        {
            'name': 'Container-based', 'pos': (11, 8), 'platforms': ['All platforms'],
            'features': ['Isolated', 'Reproducible', 'CI/CD friendly'],
            'color': '#9b59b6'
        }
    ]
    
    for tool in tools:
        # Tool box
        tool_rect = FancyBboxPatch((tool['pos'][0] - 1.5, tool['pos'][1] - 1), 3, 2, 
                                  boxstyle="round,pad=0.2", 
                                  facecolor=tool['color'], alpha=0.8,
                                  edgecolor='black', linewidth=2)
        ax.add_patch(tool_rect)
        
        # Tool name
        ax.text(tool['pos'][0], tool['pos'][1] + 0.5, tool['name'], 
                ha='center', va='center', fontsize=12, fontweight='bold', color='white')
        
        # Platforms
        platforms_text = '\n'.join(tool['platforms'])
        ax.text(tool['pos'][0], tool['pos'][1], platforms_text, 
                ha='center', va='center', fontsize=9, color='white')
        
        # Features
        features_text = '\n'.join([f"• {feature}" for feature in tool['features']])
        ax.text(tool['pos'][0], tool['pos'][1] - 0.7, features_text, 
                ha='center', va='center', fontsize=8, color='white')
    
    # Version timeline
    ax.text(7, 5.5, 'Terraform Version Timeline', ha='center', va='center', 
            fontsize=14, fontweight='bold')
    
    versions = [
        {'version': '1.0.0', 'date': '2021-06', 'pos': 2},
        {'version': '1.2.0', 'date': '2022-05', 'pos': 4},
        {'version': '1.4.0', 'date': '2023-03', 'pos': 6},
        {'version': '1.5.0', 'date': '2023-06', 'pos': 8},
        {'version': '1.6.0', 'date': '2023-10', 'pos': 10},
        {'version': '1.7.0', 'date': '2024-01', 'pos': 12}
    ]
    
    # Timeline line
    ax.plot([1, 13], [4.5, 4.5], 'black', linewidth=3)
    
    for version in versions:
        # Version marker
        ax.plot(version['pos'], 4.5, 'o', markersize=10, color='red')
        
        # Version label
        ax.text(version['pos'], 4.8, version['version'], 
                ha='center', va='bottom', fontsize=9, fontweight='bold')
        ax.text(version['pos'], 4.2, version['date'], 
                ha='center', va='top', fontsize=8)
    
    # Best practices box
    practices_rect = FancyBboxPatch((2, 1), 10, 2, boxstyle="round,pad=0.2", 
                                   facecolor='lightyellow', alpha=0.9,
                                   edgecolor='orange', linewidth=2)
    ax.add_patch(practices_rect)
    
    practices_text = """Version Management Best Practices:
• Pin Terraform version in terraform.tf files
• Use version constraints (>= 1.5.0, < 2.0.0)
• Test upgrades in non-production environments first
• Maintain compatibility with team and CI/CD systems
• Document version requirements in project README"""
    
    ax.text(7, 2, practices_text, ha='center', va='center', 
            fontsize=10, fontweight='bold')
    
    plt.tight_layout()
    plt.savefig(f'{output_dir}/version_management.png', dpi=300, bbox_inches='tight')
    plt.close()

def create_troubleshooting_flowchart():
    """Create a troubleshooting flowchart for common installation issues"""
    fig, ax = plt.subplots(figsize=(16, 12))
    ax.set_title('Terraform CLI Installation Troubleshooting Flowchart', 
                 fontsize=16, fontweight='bold')
    ax.set_xlim(0, 16)
    ax.set_ylim(0, 12)
    ax.axis('off')
    
    # Start node
    start_rect = FancyBboxPatch((7, 10.5), 2, 1, boxstyle="round,pad=0.1", 
                               facecolor='lightgreen', edgecolor='black', linewidth=2)
    ax.add_patch(start_rect)
    ax.text(8, 11, 'Installation\nIssue?', ha='center', va='center', 
            fontsize=10, fontweight='bold')
    
    # Decision nodes and solutions
    nodes = [
        {
            'type': 'decision', 'text': 'Command\nNot Found?', 'pos': (8, 9),
            'color': 'lightblue', 'yes_to': (5, 7.5), 'no_to': (11, 7.5)
        },
        {
            'type': 'solution', 'text': 'Check PATH\nVariable', 'pos': (5, 7.5),
            'color': 'lightcoral', 'next': (5, 6)
        },
        {
            'type': 'decision', 'text': 'Permission\nDenied?', 'pos': (11, 7.5),
            'color': 'lightblue', 'yes_to': (13, 6), 'no_to': (9, 6)
        },
        {
            'type': 'solution', 'text': 'Add to PATH:\nexport PATH="/usr/local/bin:$PATH"', 
             'pos': (5, 6), 'color': 'lightgreen', 'next': (5, 4.5)
        },
        {
            'type': 'solution', 'text': 'Use sudo or\nUser Directory', 'pos': (13, 6),
            'color': 'lightgreen', 'next': (13, 4.5)
        },
        {
            'type': 'decision', 'text': 'Provider\nDownload Fails?', 'pos': (9, 6),
            'color': 'lightblue', 'yes_to': (7, 4.5), 'no_to': (11, 4.5)
        },
        {
            'type': 'solution', 'text': 'Verify Installation:\nterraform version', 
             'pos': (5, 4.5), 'color': 'lightgreen', 'next': (8, 3)
        },
        {
            'type': 'solution', 'text': 'Check Network/Proxy:\nterraform init -upgrade', 
             'pos': (7, 4.5), 'color': 'lightgreen', 'next': (8, 3)
        },
        {
            'type': 'solution', 'text': 'Check API Key:\necho $IBMCLOUD_API_KEY', 
             'pos': (11, 4.5), 'color': 'lightgreen', 'next': (8, 3)
        },
        {
            'type': 'solution', 'text': 'chmod +x terraform', 'pos': (13, 4.5),
            'color': 'lightgreen', 'next': (8, 3)
        },
        {
            'type': 'end', 'text': 'Installation\nSuccessful!', 'pos': (8, 3),
            'color': 'gold'
        }
    ]
    
    # Draw nodes
    for node in nodes:
        if node['type'] == 'decision':
            # Diamond shape for decisions
            rect = FancyBboxPatch((node['pos'][0] - 1, node['pos'][1] - 0.5), 2, 1, 
                                 boxstyle="round,pad=0.1", 
                                 facecolor=node['color'], edgecolor='black', linewidth=1)
        else:
            # Rectangle for solutions/end
            rect = FancyBboxPatch((node['pos'][0] - 1.2, node['pos'][1] - 0.4), 2.4, 0.8, 
                                 boxstyle="round,pad=0.1", 
                                 facecolor=node['color'], edgecolor='black', linewidth=1)
        
        ax.add_patch(rect)
        ax.text(node['pos'][0], node['pos'][1], node['text'], 
                ha='center', va='center', fontsize=8, fontweight='bold')
    
    # Draw arrows
    arrows = [
        ((8, 10.5), (8, 9.5)),  # Start to first decision
        ((8, 8.5), (5, 8)),     # First decision to PATH check (Yes)
        ((8, 8.5), (11, 8)),    # First decision to permission check (No)
        ((5, 7), (5, 6.5)),     # PATH check to solution
        ((11, 7), (13, 6.5)),   # Permission check to sudo (Yes)
        ((11, 7), (9, 6.5)),    # Permission check to provider check (No)
        ((5, 5.5), (5, 5)),     # PATH solution to verify
        ((9, 5.5), (7, 5)),     # Provider check to network (Yes)
        ((9, 5.5), (11, 5)),    # Provider check to API key (No)
        ((13, 5.5), (13, 5)),   # Sudo solution to chmod
        ((5, 4), (8, 3.5)),     # Verify to end
        ((7, 4), (8, 3.5)),     # Network to end
        ((11, 4), (8, 3.5)),    # API key to end
        ((13, 4), (8, 3.5)),    # chmod to end
    ]
    
    for start, end in arrows:
        ax.annotate('', xy=end, xytext=start,
                   arrowprops=dict(arrowstyle='->', lw=1.5, color='black'))
    
    # Add Yes/No labels
    ax.text(6.5, 8.2, 'Yes', ha='center', va='center', fontsize=8, color='green', fontweight='bold')
    ax.text(9.5, 8.2, 'No', ha='center', va='center', fontsize=8, color='red', fontweight='bold')
    ax.text(12, 6.8, 'Yes', ha='center', va='center', fontsize=8, color='green', fontweight='bold')
    ax.text(10, 6.8, 'No', ha='center', va='center', fontsize=8, color='red', fontweight='bold')
    ax.text(8, 5.2, 'Yes', ha='center', va='center', fontsize=8, color='green', fontweight='bold')
    ax.text(10, 5.2, 'No', ha='center', va='center', fontsize=8, color='red', fontweight='bold')
    
    plt.tight_layout()
    plt.savefig(f'{output_dir}/troubleshooting_flowchart.png', dpi=300, bbox_inches='tight')
    plt.close()

def generate_all_diagrams():
    """Generate all Terraform CLI installation diagrams"""
    print("Generating Terraform CLI Installation diagrams...")
    
    create_installation_methods_diagram()
    print("✓ Installation methods diagram created")
    
    create_terraform_architecture_diagram()
    print("✓ Terraform architecture diagram created")
    
    create_installation_workflow_diagram()
    print("✓ Installation workflow diagram created")
    
    create_version_management_diagram()
    print("✓ Version management diagram created")
    
    create_troubleshooting_flowchart()
    print("✓ Troubleshooting flowchart created")
    
    print(f"\nAll diagrams have been generated and saved to '{output_dir}/' directory")
    print("\nGenerated files:")
    for file in sorted(os.listdir(output_dir)):
        if file.endswith('.png'):
            print(f"  - {file}")

if __name__ == "__main__":
    generate_all_diagrams()
