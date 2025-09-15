#!/usr/bin/env python3
"""
IBM Cloud Provider Configuration Diagrams Generator
Topic 2.2: Configuring IBM Cloud Provider

This script generates professional diagrams for IBM Cloud provider configuration concepts
using enterprise-grade visual standards and modern design principles.

Generated Diagrams:
1. Authentication Methods Comparison
2. Provider Configuration Architecture
3. Multi-Region Deployment Strategy
4. Enterprise Security Framework
5. Performance Optimization Workflow

Author: IBM Cloud Terraform Training Program
Version: 2.2.0
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, Rectangle, Circle, ConnectionPatch, Polygon
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
    'gradient_end': '#764ba2',   # Gradient Purple
    'ibm_blue': '#0f62fe',     # IBM Official Blue
    'ibm_gray': '#525252',     # IBM Gray
    'security': '#da1e28',     # IBM Red for security
    'performance': '#24a148'   # IBM Green for performance
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

def create_professional_figure(figsize=(18, 12), title="", subtitle=""):
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

def create_authentication_methods_diagram():
    """Create a comprehensive diagram showing IBM Cloud provider authentication methods"""
    fig, ax = create_professional_figure(
        figsize=(20, 14), 
        title='IBM Cloud Provider Authentication Methods',
        subtitle='Comprehensive guide to secure authentication strategies for enterprise environments'
    )
    ax.set_xlim(0, 20)
    ax.set_ylim(0, 14)
    ax.axis('off')
    
    # Authentication methods with detailed information
    auth_methods = [
        {
            'name': 'API Key Authentication', 'x': 4, 'y': 10, 'color': COLORS['primary'],
            'icon': '🔑', 'security': 'High', 'complexity': 'Low', 'recommended': True,
            'features': ['Personal API Keys', 'Service ID Keys', 'Environment Variables', 'Secure Storage'],
            'use_cases': ['Development', 'CI/CD Pipelines', 'Automation Scripts']
        },
        {
            'name': 'IAM Trusted Profiles', 'x': 10, 'y': 10, 'color': COLORS['success'],
            'icon': '🛡️', 'security': 'Very High', 'complexity': 'Medium', 'recommended': True,
            'features': ['Workload Identity', 'Conditional Access', 'No Long-term Secrets', 'SAML Integration'],
            'use_cases': ['Enterprise Workloads', 'Kubernetes Pods', 'Serverless Functions']
        },
        {
            'name': 'Multi-Account Strategy', 'x': 16, 'y': 10, 'color': COLORS['warning'],
            'icon': '🏢', 'security': 'High', 'complexity': 'High', 'recommended': True,
            'features': ['Account Isolation', 'Cross-Account Access', 'Centralized Management', 'Audit Trails'],
            'use_cases': ['Enterprise Environments', 'Multi-Tenant Systems', 'Compliance Requirements']
        }
    ]
    
    # Draw authentication method boxes
    for method in auth_methods:
        # Main method box with gradient
        create_gradient_box(ax, (method['x'] - 2, method['y'] - 1), (4, 6), 
                           method['color'], COLORS['light'], alpha=0.9)
        
        # Method border
        method_rect = FancyBboxPatch((method['x'] - 2, method['y'] - 1), 4, 6, 
                                   boxstyle="round,pad=0.1", 
                                   facecolor='none', edgecolor=COLORS['dark'], 
                                   linewidth=2.5)
        ax.add_patch(method_rect)
        
        # Method icon and name
        ax.text(method['x'], method['y'] + 4.5, method['icon'], ha='center', va='center', 
                fontsize=28)
        ax.text(method['x'], method['y'] + 3.8, method['name'], ha='center', va='center', 
                fontsize=FONT_SIZES['heading'], fontweight='bold', color='white')
        
        # Security and complexity indicators
        ax.text(method['x'], method['y'] + 3.2, f"Security: {method['security']}", 
                ha='center', va='center', fontsize=FONT_SIZES['caption'], 
                color='white', fontweight='bold')
        ax.text(method['x'], method['y'] + 2.8, f"Complexity: {method['complexity']}", 
                ha='center', va='center', fontsize=FONT_SIZES['caption'], 
                color='white', style='italic')
        
        # Features list
        for i, feature in enumerate(method['features']):
            ax.text(method['x'], method['y'] + 2.2 - (i * 0.3), f"• {feature}", 
                    ha='center', va='center', fontsize=FONT_SIZES['small'], 
                    color='white')
        
        # Recommended badge
        if method['recommended']:
            badge_rect = FancyBboxPatch((method['x'] - 1.8, method['y'] + 4.8), 1.2, 0.4, 
                                      boxstyle="round,pad=0.05", 
                                      facecolor='gold', alpha=0.9,
                                      edgecolor=COLORS['dark'], linewidth=1)
            ax.add_patch(badge_rect)
            ax.text(method['x'] - 1.2, method['y'] + 5, 'RECOMMENDED', ha='center', va='center', 
                    fontsize=FONT_SIZES['small'], fontweight='bold', color=COLORS['dark'])
    
    # Security comparison matrix
    security_matrix = {
        'API Key': {'credential_rotation': 'Manual', 'secret_exposure': 'Medium', 'audit_trail': 'Good'},
        'Trusted Profile': {'credential_rotation': 'Automatic', 'secret_exposure': 'None', 'audit_trail': 'Excellent'},
        'Multi-Account': {'credential_rotation': 'Configurable', 'secret_exposure': 'Low', 'audit_trail': 'Excellent'}
    }
    
    # Security comparison table
    table_rect = FancyBboxPatch((2, 2), 16, 4, boxstyle="round,pad=0.2", 
                              facecolor=COLORS['light'], alpha=0.95,
                              edgecolor=COLORS['primary'], linewidth=2)
    ax.add_patch(table_rect)
    
    ax.text(10, 5.5, 'Security Comparison Matrix', ha='center', va='center', 
            fontsize=FONT_SIZES['subtitle'], fontweight='bold', color=COLORS['dark'])
    
    # Table headers
    headers = ['Authentication Method', 'Credential Rotation', 'Secret Exposure Risk', 'Audit Trail Quality']
    for i, header in enumerate(headers):
        ax.text(3 + i * 3.5, 4.8, header, ha='center', va='center', 
                fontsize=FONT_SIZES['body'], fontweight='bold', color=COLORS['primary'])
    
    # Table data
    methods_data = ['API Key', 'Trusted Profile', 'Multi-Account']
    for i, method in enumerate(methods_data):
        y_pos = 4.3 - i * 0.4
        ax.text(3, y_pos, method, ha='center', va='center', 
                fontsize=FONT_SIZES['body'], color=COLORS['dark'])
        
        data = security_matrix[method]
        ax.text(6.5, y_pos, data['credential_rotation'], ha='center', va='center', 
                fontsize=FONT_SIZES['body'], color=COLORS['dark'])
        ax.text(10, y_pos, data['secret_exposure'], ha='center', va='center', 
                fontsize=FONT_SIZES['body'], color=COLORS['dark'])
        ax.text(13.5, y_pos, data['audit_trail'], ha='center', va='center', 
                fontsize=FONT_SIZES['body'], color=COLORS['dark'])
    
    # Best practices panel
    best_practices_rect = FancyBboxPatch((1, 6.5), 18, 2, boxstyle="round,pad=0.15", 
                                       facecolor=COLORS['success'], alpha=0.1,
                                       edgecolor=COLORS['success'], linewidth=2)
    ax.add_patch(best_practices_rect)
    
    ax.text(10, 8, '🏆 Enterprise Best Practices', ha='center', va='center', 
            fontsize=FONT_SIZES['subtitle'], fontweight='bold', color=COLORS['success'])
    
    best_practices = [
        "1. Use Service IDs for automation and CI/CD pipelines",
        "2. Implement least-privilege access with specific IAM policies",
        "3. Rotate API keys regularly (every 90 days minimum)",
        "4. Store credentials securely using HashiCorp Vault or similar",
        "5. Enable audit logging for all authentication events",
        "6. Use trusted profiles for workload identity in production"
    ]
    
    for i, practice in enumerate(best_practices):
        x_pos = 2 if i < 3 else 11
        y_pos = 7.5 - (i % 3) * 0.3
        ax.text(x_pos, y_pos, practice, ha='left', va='center', 
                fontsize=FONT_SIZES['body'], color=COLORS['dark'])
    
    # Add watermark
    add_watermark(ax)
    
    plt.tight_layout()
    plt.savefig(f'{output_dir}/authentication_methods.png', dpi=300, bbox_inches='tight', 
                facecolor='white', edgecolor='none')
    plt.close()

def create_provider_architecture_diagram():
    """Create a diagram showing IBM Cloud provider architecture and configuration flow"""
    fig, ax = create_professional_figure(
        figsize=(20, 14), 
        title='IBM Cloud Provider Architecture and Configuration Flow',
        subtitle='Understanding the provider initialization and resource management lifecycle'
    )
    ax.set_xlim(0, 20)
    ax.set_ylim(0, 14)
    ax.axis('off')
    
    # Architecture components
    components = [
        {'name': 'Terraform Core', 'x': 3, 'y': 11, 'width': 3, 'height': 2, 'color': COLORS['primary']},
        {'name': 'IBM Cloud Provider', 'x': 8.5, 'y': 11, 'width': 3, 'height': 2, 'color': COLORS['ibm_blue']},
        {'name': 'IBM Cloud APIs', 'x': 14, 'y': 11, 'width': 3, 'height': 2, 'color': COLORS['success']},
        {'name': 'Configuration Files', 'x': 3, 'y': 8, 'width': 3, 'height': 1.5, 'color': COLORS['warning']},
        {'name': 'State Management', 'x': 8.5, 'y': 8, 'width': 3, 'height': 1.5, 'color': COLORS['info']},
        {'name': 'IBM Cloud Resources', 'x': 14, 'y': 8, 'width': 3, 'height': 1.5, 'color': COLORS['accent']}
    ]
    
    # Draw components
    for comp in components:
        # Component box with gradient
        create_gradient_box(ax, (comp['x'] - comp['width']/2, comp['y'] - comp['height']/2), 
                           (comp['width'], comp['height']), comp['color'], COLORS['light'], alpha=0.8)
        
        # Component border
        comp_rect = FancyBboxPatch((comp['x'] - comp['width']/2, comp['y'] - comp['height']/2), 
                                 comp['width'], comp['height'], 
                                 boxstyle="round,pad=0.1", 
                                 facecolor='none', edgecolor=COLORS['dark'], 
                                 linewidth=2)
        ax.add_patch(comp_rect)
        
        # Component name
        ax.text(comp['x'], comp['y'], comp['name'], ha='center', va='center', 
                fontsize=FONT_SIZES['body'], fontweight='bold', color='white')
    
    # Configuration flow arrows
    flow_arrows = [
        {'start': (4.5, 11), 'end': (7, 11), 'label': 'Provider\nInitialization'},
        {'start': (10, 11), 'end': (12.5, 11), 'label': 'API\nCalls'},
        {'start': (4.5, 9.5), 'end': (7, 9.5), 'label': 'State\nUpdates'},
        {'start': (10, 9.5), 'end': (12.5, 9.5), 'label': 'Resource\nManagement'},
        {'start': (4.5, 8.75), 'end': (4.5, 10), 'label': 'Config\nReads'},
        {'start': (15.5, 9.5), 'end': (15.5, 10), 'label': 'Resource\nStatus'}
    ]
    
    for arrow in flow_arrows:
        create_professional_arrow(ax, arrow['start'], arrow['end'], 
                                color=COLORS['primary'], linewidth=2.5)
        # Add label
        mid_x = (arrow['start'][0] + arrow['end'][0]) / 2
        mid_y = (arrow['start'][1] + arrow['end'][1]) / 2 + 0.5
        ax.text(mid_x, mid_y, arrow['label'], ha='center', va='center', 
                fontsize=FONT_SIZES['caption'], color=COLORS['primary'], 
                fontweight='bold')
    
    # Provider configuration details
    config_details = {
        'Authentication': ['API Key', 'Trusted Profile', 'Service ID'],
        'Regional Settings': ['Region', 'Zone', 'Endpoints'],
        'Performance': ['Timeout', 'Retries', 'Parallelism'],
        'Security': ['Private Endpoints', 'Encryption', 'Audit Logging']
    }
    
    # Configuration details panel
    details_rect = FancyBboxPatch((1, 3), 18, 4, boxstyle="round,pad=0.2", 
                                facecolor=COLORS['light'], alpha=0.95,
                                edgecolor=COLORS['primary'], linewidth=2)
    ax.add_patch(details_rect)
    
    ax.text(10, 6.5, 'Provider Configuration Categories', ha='center', va='center', 
            fontsize=FONT_SIZES['subtitle'], fontweight='bold', color=COLORS['dark'])
    
    # Draw configuration categories
    x_positions = [3.5, 7.5, 11.5, 15.5]
    for i, (category, items) in enumerate(config_details.items()):
        x_pos = x_positions[i]
        
        # Category header
        ax.text(x_pos, 5.8, category, ha='center', va='center', 
                fontsize=FONT_SIZES['body'], fontweight='bold', color=COLORS['primary'])
        
        # Category items
        for j, item in enumerate(items):
            ax.text(x_pos, 5.4 - j * 0.3, f"• {item}", ha='center', va='center', 
                    fontsize=FONT_SIZES['caption'], color=COLORS['dark'])
    
    # Performance optimization workflow
    optimization_steps = [
        {'step': '1', 'title': 'Provider Tuning', 'desc': 'Configure timeouts and retries'},
        {'step': '2', 'title': 'Endpoint Selection', 'desc': 'Choose private vs public endpoints'},
        {'step': '3', 'title': 'Parallelism', 'desc': 'Optimize concurrent operations'},
        {'step': '4', 'title': 'Monitoring', 'desc': 'Enable tracing and logging'}
    ]
    
    # Optimization workflow
    workflow_rect = FancyBboxPatch((2, 0.5), 16, 2, boxstyle="round,pad=0.15", 
                                 facecolor=COLORS['performance'], alpha=0.1,
                                 edgecolor=COLORS['performance'], linewidth=2)
    ax.add_patch(workflow_rect)
    
    ax.text(10, 2.2, '⚡ Performance Optimization Workflow', ha='center', va='center', 
            fontsize=FONT_SIZES['subtitle'], fontweight='bold', color=COLORS['performance'])
    
    for i, step in enumerate(optimization_steps):
        x_pos = 3.5 + i * 3.5
        
        # Step circle
        step_circle = Circle((x_pos, 1.5), 0.3, facecolor=COLORS['performance'], 
                           edgecolor=COLORS['dark'], linewidth=2)
        ax.add_patch(step_circle)
        ax.text(x_pos, 1.5, step['step'], ha='center', va='center', 
                fontsize=FONT_SIZES['body'], fontweight='bold', color='white')
        
        # Step details
        ax.text(x_pos, 1, step['title'], ha='center', va='center', 
                fontsize=FONT_SIZES['caption'], fontweight='bold', color=COLORS['dark'])
        ax.text(x_pos, 0.7, step['desc'], ha='center', va='center', 
                fontsize=FONT_SIZES['small'], color=COLORS['dark'])
        
        # Arrow to next step
        if i < len(optimization_steps) - 1:
            create_professional_arrow(ax, (x_pos + 0.4, 1.5), (x_pos + 3.1, 1.5), 
                                    color=COLORS['performance'], linewidth=2)
    
    # Add watermark
    add_watermark(ax)
    
    plt.tight_layout()
    plt.savefig(f'{output_dir}/provider_architecture.png', dpi=300, bbox_inches='tight', 
                facecolor='white', edgecolor='none')
    plt.close()

def create_multi_region_strategy_diagram():
    """Create a diagram showing multi-region deployment strategy"""
    fig, ax = create_professional_figure(
        figsize=(20, 14),
        title='Multi-Region Deployment Strategy with IBM Cloud Provider',
        subtitle='Enterprise-grade global infrastructure deployment patterns and best practices'
    )
    ax.set_xlim(0, 20)
    ax.set_ylim(0, 14)
    ax.axis('off')

    # Global regions with their characteristics
    regions = [
        {'name': 'US South', 'code': 'us-south', 'x': 4, 'y': 10, 'color': COLORS['primary'],
         'zones': 3, 'latency': '< 5ms', 'compliance': 'SOC 2', 'primary': True},
        {'name': 'US East', 'code': 'us-east', 'x': 8, 'y': 10, 'color': COLORS['info'],
         'zones': 3, 'latency': '< 8ms', 'compliance': 'SOC 2', 'primary': False},
        {'name': 'EU Germany', 'code': 'eu-de', 'x': 12, 'y': 10, 'color': COLORS['success'],
         'zones': 3, 'latency': '< 10ms', 'compliance': 'GDPR', 'primary': False},
        {'name': 'Japan Tokyo', 'code': 'jp-tok', 'x': 16, 'y': 10, 'color': COLORS['warning'],
         'zones': 3, 'latency': '< 12ms', 'compliance': 'Local', 'primary': False}
    ]

    # Draw region boxes
    for region in regions:
        # Region box with gradient
        box_color = region['color'] if not region['primary'] else COLORS['accent']
        create_gradient_box(ax, (region['x'] - 1.5, region['y'] - 1.5), (3, 3),
                           box_color, COLORS['light'], alpha=0.8)

        # Region border
        border_width = 3 if region['primary'] else 2
        region_rect = FancyBboxPatch((region['x'] - 1.5, region['y'] - 1.5), 3, 3,
                                   boxstyle="round,pad=0.1",
                                   facecolor='none', edgecolor=COLORS['dark'],
                                   linewidth=border_width)
        ax.add_patch(region_rect)

        # Region details
        ax.text(region['x'], region['y'] + 1, region['name'], ha='center', va='center',
                fontsize=FONT_SIZES['body'], fontweight='bold', color='white')
        ax.text(region['x'], region['y'] + 0.5, region['code'], ha='center', va='center',
                fontsize=FONT_SIZES['caption'], color='white', style='italic')
        ax.text(region['x'], region['y'], f"Zones: {region['zones']}", ha='center', va='center',
                fontsize=FONT_SIZES['small'], color='white')
        ax.text(region['x'], region['y'] - 0.4, f"Latency: {region['latency']}", ha='center', va='center',
                fontsize=FONT_SIZES['small'], color='white')
        ax.text(region['x'], region['y'] - 0.8, region['compliance'], ha='center', va='center',
                fontsize=FONT_SIZES['small'], color='white', fontweight='bold')

        # Primary region indicator
        if region['primary']:
            crown_rect = FancyBboxPatch((region['x'] - 0.5, region['y'] + 1.3), 1, 0.3,
                                      boxstyle="round,pad=0.05",
                                      facecolor='gold', alpha=0.9,
                                      edgecolor=COLORS['dark'], linewidth=1)
            ax.add_patch(crown_rect)
            ax.text(region['x'], region['y'] + 1.45, 'PRIMARY', ha='center', va='center',
                    fontsize=FONT_SIZES['small'], fontweight='bold', color=COLORS['dark'])

    # Inter-region connections
    connections = [
        {'from': (5.5, 10), 'to': (6.5, 10), 'type': 'replication'},
        {'from': (9.5, 10), 'to': (10.5, 10), 'type': 'backup'},
        {'from': (13.5, 10), 'to': (14.5, 10), 'type': 'disaster_recovery'}
    ]

    for conn in connections:
        create_professional_arrow(ax, conn['from'], conn['to'],
                                color=COLORS['primary'], linewidth=2)
        mid_x = (conn['from'][0] + conn['to'][0]) / 2
        ax.text(mid_x, 10.5, conn['type'].replace('_', ' ').title(),
                ha='center', va='center', fontsize=FONT_SIZES['caption'],
                color=COLORS['primary'], fontweight='bold')

    # Deployment strategies
    strategies = [
        {'name': 'Active-Active', 'desc': 'Load balanced across regions', 'rto': '< 1 min', 'rpo': '< 5 min'},
        {'name': 'Active-Passive', 'desc': 'Primary with standby regions', 'rto': '< 15 min', 'rpo': '< 30 min'},
        {'name': 'Multi-Active', 'desc': 'Regional independence', 'rto': '< 30 sec', 'rpo': '< 1 min'}
    ]

    # Strategy comparison table
    strategy_rect = FancyBboxPatch((2, 5), 16, 3, boxstyle="round,pad=0.2",
                                 facecolor=COLORS['light'], alpha=0.95,
                                 edgecolor=COLORS['primary'], linewidth=2)
    ax.add_patch(strategy_rect)

    ax.text(10, 7.5, 'Multi-Region Deployment Strategies', ha='center', va='center',
            fontsize=FONT_SIZES['subtitle'], fontweight='bold', color=COLORS['dark'])

    # Strategy table headers
    headers = ['Strategy', 'Description', 'RTO', 'RPO']
    for i, header in enumerate(headers):
        ax.text(3.5 + i * 3.5, 7, header, ha='center', va='center',
                fontsize=FONT_SIZES['body'], fontweight='bold', color=COLORS['primary'])

    # Strategy data
    for i, strategy in enumerate(strategies):
        y_pos = 6.5 - i * 0.4
        ax.text(3.5, y_pos, strategy['name'], ha='center', va='center',
                fontsize=FONT_SIZES['body'], color=COLORS['dark'], fontweight='bold')
        ax.text(7, y_pos, strategy['desc'], ha='center', va='center',
                fontsize=FONT_SIZES['body'], color=COLORS['dark'])
        ax.text(10.5, y_pos, strategy['rto'], ha='center', va='center',
                fontsize=FONT_SIZES['body'], color=COLORS['success'], fontweight='bold')
        ax.text(14, y_pos, strategy['rpo'], ha='center', va='center',
                fontsize=FONT_SIZES['body'], color=COLORS['success'], fontweight='bold')

    # Provider configuration example
    config_rect = FancyBboxPatch((1, 1), 18, 3, boxstyle="round,pad=0.15",
                                facecolor=COLORS['dark'], alpha=0.1,
                                edgecolor=COLORS['dark'], linewidth=2)
    ax.add_patch(config_rect)

    ax.text(10, 3.5, '⚙️ Multi-Region Provider Configuration Example', ha='center', va='center',
            fontsize=FONT_SIZES['subtitle'], fontweight='bold', color=COLORS['dark'])

    config_example = [
        'provider "ibm" {',
        '  alias = "us_south"',
        '  region = "us-south"',
        '}',
        '',
        'provider "ibm" {',
        '  alias = "eu_de"',
        '  region = "eu-de"',
        '}'
    ]

    for i, line in enumerate(config_example):
        ax.text(2, 3 - i * 0.2, line, ha='left', va='center',
                fontsize=FONT_SIZES['caption'], color=COLORS['dark'],
                fontfamily='monospace')

    # Add watermark
    add_watermark(ax)

    plt.tight_layout()
    plt.savefig(f'{output_dir}/multi_region_strategy.png', dpi=300, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    plt.close()

def create_enterprise_security_diagram():
    """Create a diagram showing enterprise security framework for IBM Cloud provider"""
    fig, ax = create_professional_figure(
        figsize=(20, 14),
        title='Enterprise Security Framework for IBM Cloud Provider',
        subtitle='Comprehensive security controls and compliance strategies for production environments'
    )
    ax.set_xlim(0, 20)
    ax.set_ylim(0, 14)
    ax.axis('off')

    # Security layers
    security_layers = [
        {'name': 'Identity & Access', 'y': 11, 'color': COLORS['security'],
         'controls': ['IAM Policies', 'Service IDs', 'Trusted Profiles', 'MFA']},
        {'name': 'Network Security', 'y': 9, 'color': COLORS['primary'],
         'controls': ['Private Endpoints', 'Security Groups', 'NACLs', 'VPN']},
        {'name': 'Data Protection', 'y': 7, 'color': COLORS['success'],
         'controls': ['Encryption at Rest', 'Encryption in Transit', 'Key Management', 'Backup']},
        {'name': 'Compliance & Audit', 'y': 5, 'color': COLORS['warning'],
         'controls': ['Activity Tracker', 'Compliance Reports', 'Policy Enforcement', 'Monitoring']}
    ]

    # Draw security layers
    for i, layer in enumerate(security_layers):
        # Layer background
        layer_rect = FancyBboxPatch((1, layer['y'] - 0.8), 18, 1.6,
                                  boxstyle="round,pad=0.1",
                                  facecolor=layer['color'], alpha=0.1,
                                  edgecolor=layer['color'], linewidth=2)
        ax.add_patch(layer_rect)

        # Layer name
        ax.text(2.5, layer['y'], layer['name'], ha='center', va='center',
                fontsize=FONT_SIZES['body'], fontweight='bold', color=layer['color'])

        # Security controls
        for j, control in enumerate(layer['controls']):
            x_pos = 5 + j * 3.5
            control_rect = FancyBboxPatch((x_pos - 1, layer['y'] - 0.3), 2, 0.6,
                                        boxstyle="round,pad=0.05",
                                        facecolor=layer['color'], alpha=0.8,
                                        edgecolor=COLORS['dark'], linewidth=1)
            ax.add_patch(control_rect)
            ax.text(x_pos, layer['y'], control, ha='center', va='center',
                    fontsize=FONT_SIZES['caption'], color='white', fontweight='bold')

    # Security implementation matrix
    implementation_rect = FancyBboxPatch((2, 1), 16, 3, boxstyle="round,pad=0.2",
                                       facecolor=COLORS['light'], alpha=0.95,
                                       edgecolor=COLORS['security'], linewidth=2)
    ax.add_patch(implementation_rect)

    ax.text(10, 3.5, '🔒 Security Implementation Checklist', ha='center', va='center',
            fontsize=FONT_SIZES['subtitle'], fontweight='bold', color=COLORS['security'])

    checklist_items = [
        '✓ Enable private endpoints for all provider communications',
        '✓ Use service IDs with least-privilege IAM policies',
        '✓ Implement credential rotation every 90 days',
        '✓ Enable audit logging with Activity Tracker',
        '✓ Configure encryption for all data at rest and in transit',
        '✓ Implement network segmentation with security groups'
    ]

    for i, item in enumerate(checklist_items):
        x_pos = 3 if i < 3 else 11
        y_pos = 3 - (i % 3) * 0.4
        ax.text(x_pos, y_pos, item, ha='left', va='center',
                fontsize=FONT_SIZES['body'], color=COLORS['dark'])

    # Add watermark
    add_watermark(ax)

    plt.tight_layout()
    plt.savefig(f'{output_dir}/enterprise_security.png', dpi=300, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    plt.close()

def create_performance_optimization_diagram():
    """Create a diagram showing performance optimization workflow"""
    fig, ax = create_professional_figure(
        figsize=(20, 14),
        title='IBM Cloud Provider Performance Optimization Workflow',
        subtitle='Systematic approach to optimizing provider performance for enterprise workloads'
    )
    ax.set_xlim(0, 20)
    ax.set_ylim(0, 14)
    ax.axis('off')

    # Performance optimization steps
    optimization_steps = [
        {'step': '1', 'title': 'Baseline Measurement', 'x': 3, 'y': 11,
         'actions': ['Measure init time', 'Track API latency', 'Monitor resource creation'],
         'metrics': ['< 30s init', '< 2s API calls', '< 5min resources']},
        {'step': '2', 'title': 'Provider Tuning', 'x': 10, 'y': 11,
         'actions': ['Increase timeouts', 'Configure retries', 'Set parallelism'],
         'metrics': ['600s timeout', '10 retries', '20 parallel']},
        {'step': '3', 'title': 'Network Optimization', 'x': 17, 'y': 11,
         'actions': ['Use private endpoints', 'Regional proximity', 'CDN integration'],
         'metrics': ['< 50ms latency', '99.9% uptime', '< 1s response']},
        {'step': '4', 'title': 'Monitoring Setup', 'x': 3, 'y': 6,
         'actions': ['Enable tracing', 'Set up alerts', 'Dashboard creation'],
         'metrics': ['Real-time logs', '< 1min alerts', 'Live metrics']},
        {'step': '5', 'title': 'Continuous Optimization', 'x': 10, 'y': 6,
         'actions': ['Regular reviews', 'Performance testing', 'Capacity planning'],
         'metrics': ['Weekly reviews', 'Monthly tests', 'Quarterly planning']},
        {'step': '6', 'title': 'Validation & Reporting', 'x': 17, 'y': 6,
         'actions': ['Performance reports', 'SLA monitoring', 'Improvement tracking'],
         'metrics': ['Monthly reports', '99.9% SLA', '20% improvement']}
    ]

    # Draw optimization steps
    for step in optimization_steps:
        # Step circle
        step_circle = Circle((step['x'], step['y']), 0.8, facecolor=COLORS['performance'],
                           edgecolor=COLORS['dark'], linewidth=3)
        ax.add_patch(step_circle)
        ax.text(step['x'], step['y'], step['step'], ha='center', va='center',
                fontsize=FONT_SIZES['heading'], fontweight='bold', color='white')

        # Step title
        ax.text(step['x'], step['y'] - 1.5, step['title'], ha='center', va='center',
                fontsize=FONT_SIZES['body'], fontweight='bold', color=COLORS['dark'])

        # Actions box
        actions_rect = FancyBboxPatch((step['x'] - 2, step['y'] - 3), 4, 1.2,
                                    boxstyle="round,pad=0.1",
                                    facecolor=COLORS['light'], alpha=0.9,
                                    edgecolor=COLORS['performance'], linewidth=1)
        ax.add_patch(actions_rect)

        for i, action in enumerate(step['actions']):
            ax.text(step['x'], step['y'] - 2.2 - i * 0.25, f"• {action}", ha='center', va='center',
                    fontsize=FONT_SIZES['caption'], color=COLORS['dark'])

        # Metrics box
        metrics_rect = FancyBboxPatch((step['x'] - 2, step['y'] - 4.5), 4, 1,
                                    boxstyle="round,pad=0.1",
                                    facecolor=COLORS['success'], alpha=0.2,
                                    edgecolor=COLORS['success'], linewidth=1)
        ax.add_patch(metrics_rect)

        for i, metric in enumerate(step['metrics']):
            ax.text(step['x'], step['y'] - 4.2 + i * 0.25, metric, ha='center', va='center',
                    fontsize=FONT_SIZES['small'], color=COLORS['success'], fontweight='bold')

    # Flow arrows
    flow_connections = [
        ((4.5, 11), (8.5, 11)),
        ((11.5, 11), (15.5, 11)),
        ((17, 9.5), (17, 7.5)),
        ((15.5, 6), (11.5, 6)),
        ((8.5, 6), (4.5, 6)),
        ((3, 7.5), (3, 9.5))
    ]

    for start, end in flow_connections:
        create_professional_arrow(ax, start, end, color=COLORS['performance'], linewidth=2.5)

    # Performance metrics dashboard
    dashboard_rect = FancyBboxPatch((1, 0.5), 18, 2, boxstyle="round,pad=0.15",
                                  facecolor=COLORS['info'], alpha=0.1,
                                  edgecolor=COLORS['info'], linewidth=2)
    ax.add_patch(dashboard_rect)

    ax.text(10, 2, '📊 Key Performance Indicators (KPIs)', ha='center', va='center',
            fontsize=FONT_SIZES['subtitle'], fontweight='bold', color=COLORS['info'])

    kpis = [
        {'name': 'Provider Init Time', 'target': '< 30 seconds', 'current': '15 seconds'},
        {'name': 'API Response Time', 'target': '< 2 seconds', 'current': '0.8 seconds'},
        {'name': 'Resource Creation', 'target': '< 5 minutes', 'current': '2.5 minutes'},
        {'name': 'Error Rate', 'target': '< 1%', 'current': '0.2%'}
    ]

    for i, kpi in enumerate(kpis):
        x_pos = 3 + i * 4
        ax.text(x_pos, 1.5, kpi['name'], ha='center', va='center',
                fontsize=FONT_SIZES['caption'], fontweight='bold', color=COLORS['dark'])
        ax.text(x_pos, 1.2, f"Target: {kpi['target']}", ha='center', va='center',
                fontsize=FONT_SIZES['small'], color=COLORS['warning'])
        ax.text(x_pos, 0.9, f"Current: {kpi['current']}", ha='center', va='center',
                fontsize=FONT_SIZES['small'], color=COLORS['success'], fontweight='bold')

    # Add watermark
    add_watermark(ax)

    plt.tight_layout()
    plt.savefig(f'{output_dir}/performance_optimization.png', dpi=300, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    plt.close()

# Main execution
if __name__ == "__main__":
    print("Generating IBM Cloud Provider Configuration diagrams...")

    # Generate all diagrams
    create_authentication_methods_diagram()
    print("✓ Authentication methods diagram created")

    create_provider_architecture_diagram()
    print("✓ Provider architecture diagram created")

    create_multi_region_strategy_diagram()
    print("✓ Multi-region strategy diagram created")

    create_enterprise_security_diagram()
    print("✓ Enterprise security diagram created")

    create_performance_optimization_diagram()
    print("✓ Performance optimization diagram created")

    print(f"\nAll diagrams have been generated and saved to '{output_dir}/' directory")
    print("\nGenerated files:")
    for file in sorted(os.listdir(output_dir)):
        if file.endswith('.png'):
            print(f"  - {file}")
