#!/usr/bin/env python3
"""
IaC Benefits and Use Cases for IBM Cloud - Diagram as Code Implementation
This script generates visual diagrams to illustrate IaC benefits and real-world use cases.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, Circle, Rectangle
import numpy as np
import os

# Set up the output directory
output_dir = "generated_diagrams"
os.makedirs(output_dir, exist_ok=True)

def create_roi_comparison_chart():
    """Create ROI comparison between traditional and IaC approaches"""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 8))
    fig.suptitle('ROI Analysis: Traditional vs Infrastructure as Code', 
                 fontsize=16, fontweight='bold')
    
    # Traditional costs breakdown
    ax1.set_title('Traditional Infrastructure Costs', fontsize=14, fontweight='bold', color='red')
    traditional_costs = [800000, 600000]  # Personnel, Operational
    traditional_labels = ['Personnel\n$800K', 'Operational\n$600K']
    colors1 = ['#ff9999', '#ffcccc']
    
    wedges1, texts1, autotexts1 = ax1.pie(traditional_costs, labels=traditional_labels, 
                                          colors=colors1, autopct='%1.1f%%', startangle=90)
    ax1.text(0, -1.3, 'Total: $1.4M annually', ha='center', fontsize=12, fontweight='bold')
    
    # IaC costs breakdown
    ax2.set_title('IaC Implementation Costs', fontsize=14, fontweight='bold', color='green')
    iac_costs = [450000, 75000]  # Personnel, Tooling
    iac_labels = ['Personnel\n$450K', 'Tooling\n$75K']
    colors2 = ['#99ff99', '#ccffcc']
    
    wedges2, texts2, autotexts2 = ax2.pie(iac_costs, labels=iac_labels, 
                                          colors=colors2, autopct='%1.1f%%', startangle=90)
    ax2.text(0, -1.3, 'Total: $525K annually', ha='center', fontsize=12, fontweight='bold')
    
    # Add ROI information
    fig.text(0.5, 0.02, 'Annual Savings: $875K | ROI: 167% | Payback Period: 7.2 months', 
             ha='center', fontsize=14, fontweight='bold', 
             bbox=dict(boxstyle="round,pad=0.3", facecolor='lightblue'))
    
    plt.tight_layout()
    plt.savefig(f'{output_dir}/roi_comparison.png', dpi=300, bbox_inches='tight')
    plt.close()

def create_ibm_cloud_benefits_diagram():
    """Create a comprehensive benefits diagram for IBM Cloud IaC"""
    fig, ax = plt.subplots(figsize=(16, 12))
    ax.set_title('IBM Cloud Infrastructure as Code - Key Benefits', 
                 fontsize=18, fontweight='bold')
    ax.set_xlim(0, 16)
    ax.set_ylim(0, 12)
    ax.axis('off')
    
    # Central IBM Cloud logo area
    center_rect = FancyBboxPatch((6, 5), 4, 2, boxstyle="round,pad=0.3", 
                                facecolor='#1f70c1', edgecolor='navy', linewidth=3)
    ax.add_patch(center_rect)
    ax.text(8, 6, 'IBM Cloud\nIaC Benefits', ha='center', va='center', 
            fontsize=16, fontweight='bold', color='white')
    
    # Benefit categories with specific IBM Cloud advantages
    benefits = [
        {
            'pos': (2, 10), 
            'title': 'Enterprise Security', 
            'details': ['Built-in IAM', 'Key Protect', 'Activity Tracker'],
            'color': '#ff6b6b', 'icon': '🔒'
        },
        {
            'pos': (8, 10), 
            'title': 'Native Integration', 
            'details': ['Schematics', '200+ Services', 'Hybrid Cloud'],
            'color': '#4ecdc4', 'icon': '🔗'
        },
        {
            'pos': (14, 10), 
            'title': 'Cost Optimization', 
            'details': ['Auto-scaling', 'Reserved Instances', 'Smart Storage'],
            'color': '#45b7d1', 'icon': '💰'
        },
        {
            'pos': (2, 6), 
            'title': 'Compliance Automation', 
            'details': ['SOX', 'GDPR', 'HIPAA'],
            'color': '#96ceb4', 'icon': '✅'
        },
        {
            'pos': (14, 6), 
            'title': 'AI/ML Ready', 
            'details': ['Watson Services', 'Auto ML', 'Quantum Ready'],
            'color': '#feca57', 'icon': '🤖'
        },
        {
            'pos': (2, 2), 
            'title': 'Global Reach', 
            'details': ['Multi-region', 'Edge Computing', 'CDN Integration'],
            'color': '#ff9ff3', 'icon': '🌍'
        },
        {
            'pos': (8, 2), 
            'title': 'Developer Experience', 
            'details': ['GitOps', 'CI/CD Ready', 'Code Engine'],
            'color': '#54a0ff', 'icon': '👨‍💻'
        },
        {
            'pos': (14, 2), 
            'title': 'Enterprise Support', 
            'details': ['24/7 Support', 'Professional Services', 'Training'],
            'color': '#5f27cd', 'icon': '🎯'
        }
    ]
    
    for benefit in benefits:
        # Benefit box
        rect = FancyBboxPatch((benefit['pos'][0] - 1.5, benefit['pos'][1] - 1), 
                             3, 2, boxstyle="round,pad=0.2", 
                             facecolor=benefit['color'], alpha=0.8,
                             edgecolor='black', linewidth=2)
        ax.add_patch(rect)
        
        # Icon and title
        ax.text(benefit['pos'][0], benefit['pos'][1] + 0.5, benefit['icon'], 
                ha='center', va='center', fontsize=20)
        ax.text(benefit['pos'][0], benefit['pos'][1] + 0.1, benefit['title'], 
                ha='center', va='center', fontsize=11, fontweight='bold')
        
        # Details
        details_text = '\n'.join(benefit['details'])
        ax.text(benefit['pos'][0], benefit['pos'][1] - 0.4, details_text, 
                ha='center', va='center', fontsize=9)
        
        # Connection to center
        ax.plot([benefit['pos'][0], 8], [benefit['pos'][1], 6], 
                'gray', linewidth=2, alpha=0.4, linestyle='--')
    
    plt.tight_layout()
    plt.savefig(f'{output_dir}/ibm_cloud_benefits.png', dpi=300, bbox_inches='tight')
    plt.close()

def create_use_case_timeline():
    """Create a timeline showing IaC implementation phases"""
    fig, ax = plt.subplots(figsize=(18, 10))
    ax.set_title('IaC Implementation Journey: From Startup to Enterprise', 
                 fontsize=16, fontweight='bold')
    ax.set_xlim(0, 18)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Timeline phases
    phases = [
        {
            'x': 3, 'title': 'Phase 1: Startup', 'duration': '0-6 months',
            'budget': '$1K/month', 'features': ['Basic VPC', 'Single Region', 'Manual Scaling'],
            'color': '#ff6b6b'
        },
        {
            'x': 7, 'title': 'Phase 2: Growth', 'duration': '6-18 months',
            'budget': '$10K/month', 'features': ['Multi-Environment', 'Auto-scaling', 'Monitoring'],
            'color': '#4ecdc4'
        },
        {
            'x': 11, 'title': 'Phase 3: Scale', 'duration': '18-36 months',
            'budget': '$50K/month', 'features': ['Multi-Region', 'CI/CD', 'Compliance'],
            'color': '#45b7d1'
        },
        {
            'x': 15, 'title': 'Phase 4: Enterprise', 'duration': '36+ months',
            'budget': '$200K/month', 'features': ['Global Scale', 'AI/ML', 'Quantum Ready'],
            'color': '#96ceb4'
        }
    ]
    
    # Draw timeline line
    ax.plot([1, 17], [5, 5], 'black', linewidth=4)
    
    for i, phase in enumerate(phases):
        # Phase marker
        circle = Circle((phase['x'], 5), 0.3, color=phase['color'], zorder=3)
        ax.add_patch(circle)
        
        # Phase box
        rect = FancyBboxPatch((phase['x'] - 1.5, 6.5), 3, 2.5, 
                             boxstyle="round,pad=0.2", 
                             facecolor=phase['color'], alpha=0.8,
                             edgecolor='black', linewidth=2)
        ax.add_patch(rect)
        
        # Phase information
        ax.text(phase['x'], 8.5, phase['title'], ha='center', va='center', 
                fontsize=12, fontweight='bold')
        ax.text(phase['x'], 8, phase['duration'], ha='center', va='center', 
                fontsize=10, style='italic')
        ax.text(phase['x'], 7.5, phase['budget'], ha='center', va='center', 
                fontsize=10, fontweight='bold', color='darkgreen')
        
        # Features
        features_text = '\n'.join(phase['features'])
        ax.text(phase['x'], 7, features_text, ha='center', va='center', 
                fontsize=9)
        
        # Connection line
        ax.plot([phase['x'], phase['x']], [5.3, 6.5], 'black', linewidth=2)
        
        # ROI indicators below timeline
        roi_values = ['Break-even', '50% ROI', '120% ROI', '200% ROI']
        ax.text(phase['x'], 3.5, 'ROI:', ha='center', va='center', 
                fontsize=10, fontweight='bold')
        ax.text(phase['x'], 3, roi_values[i], ha='center', va='center', 
                fontsize=11, fontweight='bold', color='darkgreen')
        
        # Team size indicators
        team_sizes = ['1-2 people', '3-5 people', '5-10 people', '10+ people']
        ax.text(phase['x'], 2, 'Team Size:', ha='center', va='center', 
                fontsize=10, fontweight='bold')
        ax.text(phase['x'], 1.5, team_sizes[i], ha='center', va='center', 
                fontsize=10, color='darkblue')
    
    # Add legend
    ax.text(9, 0.5, 'Implementation Timeline: Each phase builds upon previous capabilities', 
            ha='center', va='center', fontsize=12, fontweight='bold',
            bbox=dict(boxstyle="round,pad=0.3", facecolor='lightyellow'))
    
    plt.tight_layout()
    plt.savefig(f'{output_dir}/use_case_timeline.png', dpi=300, bbox_inches='tight')
    plt.close()

def create_cost_optimization_diagram():
    """Create a diagram showing cost optimization strategies"""
    fig, ax = plt.subplots(figsize=(14, 10))
    ax.set_title('IBM Cloud IaC Cost Optimization Strategies', 
                 fontsize=16, fontweight='bold')
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Cost optimization strategies
    strategies = [
        {
            'pos': (3, 8), 'title': 'Auto-Scaling', 
            'savings': '25-40%', 'description': 'Dynamic resource allocation',
            'color': '#ff6b6b'
        },
        {
            'pos': (7, 8), 'title': 'Reserved Instances', 
            'savings': '30-60%', 'description': 'Committed use discounts',
            'color': '#4ecdc4'
        },
        {
            'pos': (11, 8), 'title': 'Smart Storage', 
            'savings': '40-70%', 'description': 'Intelligent tiering',
            'color': '#45b7d1'
        },
        {
            'pos': (3, 5), 'title': 'Resource Scheduling', 
            'savings': '20-30%', 'description': 'Off-hours automation',
            'color': '#96ceb4'
        },
        {
            'pos': (7, 5), 'title': 'Right-Sizing', 
            'savings': '15-25%', 'description': 'Optimal instance selection',
            'color': '#feca57'
        },
        {
            'pos': (11, 5), 'title': 'Lifecycle Management', 
            'savings': '35-50%', 'description': 'Automated cleanup',
            'color': '#ff9ff3'
        },
        {
            'pos': (5, 2), 'title': 'Multi-Region Optimization', 
            'savings': '10-20%', 'description': 'Geographic cost arbitrage',
            'color': '#54a0ff'
        },
        {
            'pos': (9, 2), 'title': 'Spot Instances', 
            'savings': '50-90%', 'description': 'Preemptible workloads',
            'color': '#5f27cd'
        }
    ]
    
    for strategy in strategies:
        # Strategy box
        rect = FancyBboxPatch((strategy['pos'][0] - 1.2, strategy['pos'][1] - 0.8), 
                             2.4, 1.6, boxstyle="round,pad=0.1", 
                             facecolor=strategy['color'], alpha=0.8,
                             edgecolor='black', linewidth=2)
        ax.add_patch(rect)
        
        # Title and savings
        ax.text(strategy['pos'][0], strategy['pos'][1] + 0.3, strategy['title'], 
                ha='center', va='center', fontsize=11, fontweight='bold')
        ax.text(strategy['pos'][0], strategy['pos'][1], strategy['savings'], 
                ha='center', va='center', fontsize=14, fontweight='bold', color='darkgreen')
        ax.text(strategy['pos'][0], strategy['pos'][1] - 0.3, 'savings', 
                ha='center', va='center', fontsize=9, color='darkgreen')
        ax.text(strategy['pos'][0], strategy['pos'][1] - 0.5, strategy['description'], 
                ha='center', va='center', fontsize=8, style='italic')
    
    # Add total potential savings
    total_rect = FancyBboxPatch((5, 0.2), 4, 1, boxstyle="round,pad=0.2", 
                               facecolor='gold', alpha=0.9,
                               edgecolor='black', linewidth=3)
    ax.add_patch(total_rect)
    ax.text(7, 0.7, 'Combined Potential Savings: 60-80%', 
            ha='center', va='center', fontsize=14, fontweight='bold')
    
    plt.tight_layout()
    plt.savefig(f'{output_dir}/cost_optimization.png', dpi=300, bbox_inches='tight')
    plt.close()

def create_industry_use_cases():
    """Create industry-specific use case diagram"""
    fig, ax = plt.subplots(figsize=(16, 12))
    ax.set_title('Industry-Specific IaC Use Cases on IBM Cloud', 
                 fontsize=16, fontweight='bold')
    ax.set_xlim(0, 16)
    ax.set_ylim(0, 12)
    ax.axis('off')
    
    # Industry use cases
    industries = [
        {
            'pos': (4, 9), 'name': 'Financial Services', 'icon': '🏦',
            'requirements': ['SOX Compliance', 'PCI-DSS', 'High Availability', 'Audit Trails'],
            'solutions': ['Encrypted Storage', 'Multi-Region DR', 'Activity Tracker', 'IAM Controls'],
            'color': '#ff6b6b'
        },
        {
            'pos': (12, 9), 'name': 'Healthcare', 'icon': '🏥',
            'requirements': ['HIPAA Compliance', 'Data Privacy', 'Patient Records', 'Secure Access'],
            'solutions': ['Key Protect', 'Private Networks', 'Access Logging', 'Data Residency'],
            'color': '#4ecdc4'
        },
        {
            'pos': (4, 6), 'name': 'Manufacturing', 'icon': '🏭',
            'requirements': ['IoT Integration', 'Edge Computing', 'Supply Chain', 'Predictive Analytics'],
            'solutions': ['Edge Nodes', 'Watson IoT', 'B2B Integration', 'AI/ML Services'],
            'color': '#45b7d1'
        },
        {
            'pos': (12, 6), 'name': 'Retail/E-commerce', 'icon': '🛒',
            'requirements': ['Scalability', 'Global CDN', 'Payment Security', 'Customer Analytics'],
            'solutions': ['Auto-scaling', 'Global Load Balancer', 'Secure Gateways', 'Watson Analytics'],
            'color': '#96ceb4'
        },
        {
            'pos': (4, 3), 'name': 'Government', 'icon': '🏛️',
            'requirements': ['FedRAMP', 'Data Sovereignty', 'Citizen Services', 'Transparency'],
            'solutions': ['Dedicated Hosts', 'Regional Deployment', 'Public APIs', 'Audit Compliance'],
            'color': '#feca57'
        },
        {
            'pos': (12, 3), 'name': 'Education', 'icon': '🎓',
            'requirements': ['FERPA Compliance', 'Remote Learning', 'Research Computing', 'Cost Control'],
            'solutions': ['Private Cloud', 'Video Streaming', 'HPC Clusters', 'Budget Controls'],
            'color': '#ff9ff3'
        }
    ]
    
    for industry in industries:
        # Industry box
        rect = FancyBboxPatch((industry['pos'][0] - 2, industry['pos'][1] - 1.2), 
                             4, 2.4, boxstyle="round,pad=0.2", 
                             facecolor=industry['color'], alpha=0.8,
                             edgecolor='black', linewidth=2)
        ax.add_patch(rect)
        
        # Icon and name
        ax.text(industry['pos'][0], industry['pos'][1] + 0.8, industry['icon'], 
                ha='center', va='center', fontsize=24)
        ax.text(industry['pos'][0], industry['pos'][1] + 0.4, industry['name'], 
                ha='center', va='center', fontsize=12, fontweight='bold')
        
        # Requirements (left side)
        ax.text(industry['pos'][0] - 0.8, industry['pos'][1], 'Requirements:', 
                ha='center', va='center', fontsize=9, fontweight='bold')
        req_text = '\n'.join([f"• {req}" for req in industry['requirements']])
        ax.text(industry['pos'][0] - 0.8, industry['pos'][1] - 0.5, req_text, 
                ha='center', va='center', fontsize=8)
        
        # Solutions (right side)
        ax.text(industry['pos'][0] + 0.8, industry['pos'][1], 'IaC Solutions:', 
                ha='center', va='center', fontsize=9, fontweight='bold')
        sol_text = '\n'.join([f"• {sol}" for sol in industry['solutions']])
        ax.text(industry['pos'][0] + 0.8, industry['pos'][1] - 0.5, sol_text, 
                ha='center', va='center', fontsize=8, color='darkgreen')
    
    # Add central connecting element
    center_circle = Circle((8, 6), 1, color='lightblue', alpha=0.7, zorder=1)
    ax.add_patch(center_circle)
    ax.text(8, 6, 'IBM Cloud\nIaC Platform', ha='center', va='center', 
            fontsize=12, fontweight='bold', zorder=2)
    
    # Connect industries to center
    for industry in industries:
        ax.plot([industry['pos'][0], 8], [industry['pos'][1], 6], 
                'gray', linewidth=1, alpha=0.5, linestyle='--', zorder=0)
    
    plt.tight_layout()
    plt.savefig(f'{output_dir}/industry_use_cases.png', dpi=300, bbox_inches='tight')
    plt.close()

def generate_all_diagrams():
    """Generate all benefits and use cases diagrams"""
    print("Generating IaC Benefits and Use Cases diagrams...")
    
    create_roi_comparison_chart()
    print("✓ ROI comparison chart created")
    
    create_ibm_cloud_benefits_diagram()
    print("✓ IBM Cloud benefits diagram created")
    
    create_use_case_timeline()
    print("✓ Use case timeline created")
    
    create_cost_optimization_diagram()
    print("✓ Cost optimization diagram created")
    
    create_industry_use_cases()
    print("✓ Industry use cases diagram created")
    
    print(f"\nAll diagrams have been generated and saved to '{output_dir}/' directory")
    print("\nGenerated files:")
    for file in sorted(os.listdir(output_dir)):
        if file.endswith('.png'):
            print(f"  - {file}")

if __name__ == "__main__":
    generate_all_diagrams()
