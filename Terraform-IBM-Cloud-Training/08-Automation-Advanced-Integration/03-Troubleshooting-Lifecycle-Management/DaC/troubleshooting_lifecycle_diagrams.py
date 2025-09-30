#!/usr/bin/env python3
"""
Troubleshooting & Lifecycle Management Diagrams Generator
Topic 8.3: Advanced Troubleshooting and Lifecycle Management

This script generates 5 professional diagrams for Topic 8.3 covering:
1. Advanced Debugging Architecture
2. Performance Monitoring Stack
3. Self-Healing Infrastructure
4. Performance Optimization Framework
5. Operational Excellence Dashboard

All diagrams are generated at 300 DPI with IBM Cloud branding and consistent styling.
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
    'yellow': '#f1c21b',
    'red': '#da1e28',
    'orange': '#ff832b'
}

def setup_figure(title, figsize=(16, 12)):
    """Setup figure with IBM Cloud styling"""
    fig, ax = plt.subplots(figsize=figsize, dpi=300)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')
    
    # Add title
    ax.text(50, 95, title, fontsize=20, fontweight='bold', 
            ha='center', va='center', color=IBM_COLORS['dark_blue'])
    
    # Add IBM Cloud branding
    ax.text(2, 2, 'IBM Cloud', fontsize=12, fontweight='bold', 
            ha='left', va='bottom', color=IBM_COLORS['blue'])
    
    return fig, ax

def add_component_box(ax, x, y, width, height, text, color=IBM_COLORS['blue'], text_color='white'):
    """Add a styled component box"""
    box = FancyBboxPatch((x, y), width, height,
                         boxstyle="round,pad=0.5",
                         facecolor=color,
                         edgecolor=IBM_COLORS['dark_blue'],
                         linewidth=2)
    ax.add_patch(box)
    
    ax.text(x + width/2, y + height/2, text, fontsize=10, fontweight='bold',
            ha='center', va='center', color=text_color, wrap=True)

def add_arrow(ax, start_x, start_y, end_x, end_y, color=IBM_COLORS['gray']):
    """Add styled arrow between components"""
    arrow = ConnectionPatch((start_x, start_y), (end_x, end_y), "data", "data",
                          arrowstyle="->", shrinkA=5, shrinkB=5,
                          mutation_scale=20, fc=color, ec=color, linewidth=2)
    ax.add_patch(arrow)

def generate_diagram_1_debugging_architecture():
    """Generate Figure 8.3.1: Advanced Debugging Architecture"""
    fig, ax = setup_figure("Figure 8.3.1: Advanced Debugging Architecture")
    
    # Debugging layers
    add_component_box(ax, 5, 80, 25, 12, "Terraform Debug\nLogging & Tracing", IBM_COLORS['blue'])
    add_component_box(ax, 35, 80, 25, 12, "IBM Cloud\nAPI Tracing", IBM_COLORS['light_blue'])
    add_component_box(ax, 65, 80, 30, 12, "State File Analysis\n& Validation", IBM_COLORS['dark_blue'])
    
    # Diagnostic tools
    add_component_box(ax, 5, 60, 20, 10, "Automated\nDiagnostics", IBM_COLORS['green'])
    add_component_box(ax, 30, 60, 20, 10, "Health Check\nFunctions", IBM_COLORS['green'])
    add_component_box(ax, 55, 60, 20, 10, "Performance\nProfiler", IBM_COLORS['green'])
    add_component_box(ax, 80, 60, 15, 10, "Error\nAnalyzer", IBM_COLORS['green'])
    
    # Data collection
    add_component_box(ax, 10, 40, 35, 12, "Activity Tracker\nComprehensive Audit Logging", IBM_COLORS['yellow'], 'black')
    add_component_box(ax, 50, 40, 35, 12, "Log Analysis\nCentralized Log Management", IBM_COLORS['yellow'], 'black')
    
    # Analysis and insights
    add_component_box(ax, 15, 20, 30, 12, "Intelligent Analysis\nPattern Recognition", IBM_COLORS['orange'])
    add_component_box(ax, 50, 20, 30, 12, "Predictive Insights\nIssue Prevention", IBM_COLORS['orange'])
    
    # Add arrows showing data flow
    add_arrow(ax, 17.5, 80, 17.5, 70)
    add_arrow(ax, 47.5, 80, 40, 70)
    add_arrow(ax, 77.5, 80, 65, 70)
    add_arrow(ax, 27.5, 60, 27.5, 52)
    add_arrow(ax, 67.5, 60, 67.5, 52)
    add_arrow(ax, 30, 46, 30, 32)
    add_arrow(ax, 65, 46, 65, 32)
    
    # Add legend
    ax.text(5, 10, "Key Benefits:", fontsize=12, fontweight='bold', color=IBM_COLORS['dark_blue'])
    ax.text(5, 7, "• 90% faster issue resolution", fontsize=10, color=IBM_COLORS['gray'])
    ax.text(5, 4, "• Proactive problem detection", fontsize=10, color=IBM_COLORS['gray'])
    ax.text(5, 1, "• Comprehensive audit trail", fontsize=10, color=IBM_COLORS['gray'])
    
    plt.tight_layout()
    plt.savefig('diagrams/Figure_8.3.1_Advanced_Debugging_Architecture.png', 
                dpi=300, bbox_inches='tight', facecolor='white')
    plt.close()

def generate_diagram_2_monitoring_stack():
    """Generate Figure 8.3.2: Performance Monitoring Stack"""
    fig, ax = setup_figure("Figure 8.3.2: Performance Monitoring Stack")
    
    # Monitoring layers
    add_component_box(ax, 5, 85, 20, 8, "System Metrics\nCPU, Memory, Disk", IBM_COLORS['blue'])
    add_component_box(ax, 30, 85, 20, 8, "Terraform Metrics\nState, Performance", IBM_COLORS['blue'])
    add_component_box(ax, 55, 85, 20, 8, "IBM Cloud Metrics\nAPI, Services", IBM_COLORS['blue'])
    add_component_box(ax, 80, 85, 15, 8, "Custom Metrics\nBusiness KPIs", IBM_COLORS['blue'])
    
    # Collection and processing
    add_component_box(ax, 10, 70, 25, 10, "Monitoring Service\nSysdig Integration", IBM_COLORS['green'])
    add_component_box(ax, 40, 70, 25, 10, "Event Streams\nReal-time Analytics", IBM_COLORS['green'])
    add_component_box(ax, 70, 70, 25, 10, "Log Analysis\nCentralized Logging", IBM_COLORS['green'])
    
    # Analytics and intelligence
    add_component_box(ax, 5, 50, 30, 12, "Predictive Analytics\nWatson Studio Integration", IBM_COLORS['yellow'], 'black')
    add_component_box(ax, 40, 50, 30, 12, "Intelligent Alerting\nNoise Reduction & Correlation", IBM_COLORS['yellow'], 'black')
    add_component_box(ax, 75, 50, 20, 12, "Performance\nScoring", IBM_COLORS['yellow'], 'black')
    
    # Dashboards and visualization
    add_component_box(ax, 15, 30, 25, 10, "Real-time Dashboards\nOperational Views", IBM_COLORS['orange'])
    add_component_box(ax, 45, 30, 25, 10, "Executive Reports\nBusiness Metrics", IBM_COLORS['orange'])
    add_component_box(ax, 75, 30, 20, 10, "Mobile Alerts\nOn-call Support", IBM_COLORS['orange'])
    
    # Actions and automation
    add_component_box(ax, 20, 10, 25, 12, "Automated Response\nSelf-healing Actions", IBM_COLORS['red'])
    add_component_box(ax, 50, 10, 25, 12, "Escalation Workflows\nIncident Management", IBM_COLORS['red'])
    
    # Add data flow arrows
    for x in [15, 40, 65, 87.5]:
        add_arrow(ax, x, 85, x, 80)
    
    add_arrow(ax, 22.5, 70, 22.5, 62)
    add_arrow(ax, 52.5, 70, 52.5, 62)
    add_arrow(ax, 82.5, 70, 82.5, 62)
    
    add_arrow(ax, 27.5, 30, 32.5, 22)
    add_arrow(ax, 57.5, 30, 62.5, 22)
    
    plt.tight_layout()
    plt.savefig('diagrams/Figure_8.3.2_Performance_Monitoring_Stack.png', 
                dpi=300, bbox_inches='tight', facecolor='white')
    plt.close()

def generate_diagram_3_self_healing():
    """Generate Figure 8.3.3: Self-Healing Infrastructure"""
    fig, ax = setup_figure("Figure 8.3.3: Self-Healing Infrastructure")
    
    # Detection layer
    add_component_box(ax, 5, 85, 18, 8, "Health Monitors\nContinuous Checks", IBM_COLORS['blue'])
    add_component_box(ax, 28, 85, 18, 8, "Anomaly Detection\nML-based Analysis", IBM_COLORS['blue'])
    add_component_box(ax, 51, 85, 18, 8, "Threshold Alerts\nRule-based Triggers", IBM_COLORS['blue'])
    add_component_box(ax, 74, 85, 21, 8, "Predictive Warnings\nProactive Detection", IBM_COLORS['blue'])
    
    # Analysis and decision
    add_component_box(ax, 15, 70, 30, 10, "Intelligent Analysis Engine\nRoot Cause Analysis", IBM_COLORS['green'])
    add_component_box(ax, 50, 70, 30, 10, "Decision Matrix\nRemediation Planning", IBM_COLORS['green'])
    
    # Automated actions
    add_component_box(ax, 5, 50, 20, 12, "Service Restart\nAutomatic Recovery", IBM_COLORS['yellow'], 'black')
    add_component_box(ax, 30, 50, 20, 12, "Resource Scaling\nCapacity Adjustment", IBM_COLORS['yellow'], 'black')
    add_component_box(ax, 55, 50, 20, 12, "Configuration Fix\nAuto-correction", IBM_COLORS['yellow'], 'black')
    add_component_box(ax, 80, 50, 15, 12, "Rollback\nSafe Recovery", IBM_COLORS['yellow'], 'black')
    
    # Escalation and notification
    add_component_box(ax, 10, 30, 25, 10, "Escalation Engine\nIntelligent Routing", IBM_COLORS['orange'])
    add_component_box(ax, 40, 30, 25, 10, "Notification System\nMulti-channel Alerts", IBM_COLORS['orange'])
    add_component_box(ax, 70, 30, 25, 10, "Incident Management\nTicket Creation", IBM_COLORS['orange'])
    
    # Learning and improvement
    add_component_box(ax, 20, 10, 30, 12, "Learning Engine\nPattern Recognition", IBM_COLORS['red'])
    add_component_box(ax, 55, 10, 30, 12, "Continuous Improvement\nPlaybook Updates", IBM_COLORS['red'])
    
    # Add workflow arrows
    for x in [14, 37, 60, 84.5]:
        add_arrow(ax, x, 85, x, 80)
    
    add_arrow(ax, 30, 70, 30, 62)
    add_arrow(ax, 65, 70, 65, 62)
    
    add_arrow(ax, 22.5, 30, 35, 22)
    add_arrow(ax, 52.5, 30, 52.5, 22)
    add_arrow(ax, 82.5, 30, 70, 22)
    
    # Add success metrics
    ax.text(5, 5, "Success Metrics: 85% automated resolution, 90% MTTR reduction", 
            fontsize=10, fontweight='bold', color=IBM_COLORS['dark_blue'])
    
    plt.tight_layout()
    plt.savefig('diagrams/Figure_8.3.3_Self_Healing_Infrastructure.png', 
                dpi=300, bbox_inches='tight', facecolor='white')
    plt.close()

def generate_diagram_4_optimization_framework():
    """Generate Figure 8.3.4: Performance Optimization Framework"""
    fig, ax = setup_figure("Figure 8.3.4: Performance Optimization Framework")
    
    # Performance analysis
    add_component_box(ax, 5, 85, 22, 8, "Performance Profiling\nBottleneck Identification", IBM_COLORS['blue'])
    add_component_box(ax, 32, 85, 22, 8, "Resource Utilization\nEfficiency Analysis", IBM_COLORS['blue'])
    add_component_box(ax, 59, 85, 22, 8, "Cost Analysis\nOptimization Opportunities", IBM_COLORS['blue'])
    add_component_box(ax, 86, 85, 9, 8, "Benchmarks\nTargets", IBM_COLORS['blue'])
    
    # Optimization strategies
    add_component_box(ax, 5, 65, 18, 12, "Parallel Execution\nConcurrency Tuning", IBM_COLORS['green'])
    add_component_box(ax, 28, 65, 18, 12, "Caching Strategy\nState Optimization", IBM_COLORS['green'])
    add_component_box(ax, 51, 65, 18, 12, "Resource Right-sizing\nCapacity Planning", IBM_COLORS['green'])
    add_component_box(ax, 74, 65, 21, 12, "Provider Optimization\nConnection Pooling", IBM_COLORS['green'])
    
    # Implementation
    add_component_box(ax, 10, 45, 25, 10, "Automated Optimization\nIntelligent Tuning", IBM_COLORS['yellow'], 'black')
    add_component_box(ax, 40, 45, 25, 10, "Configuration Updates\nDynamic Adjustment", IBM_COLORS['yellow'], 'black')
    add_component_box(ax, 70, 45, 25, 10, "Deployment Optimization\nPipeline Enhancement", IBM_COLORS['yellow'], 'black')
    
    # Monitoring and validation
    add_component_box(ax, 15, 25, 30, 10, "Performance Monitoring\nContinuous Measurement", IBM_COLORS['orange'])
    add_component_box(ax, 50, 25, 30, 10, "Validation Testing\nImpact Assessment", IBM_COLORS['orange'])
    
    # Results and feedback
    add_component_box(ax, 20, 5, 25, 12, "Performance Gains\n75% Improvement", IBM_COLORS['red'])
    add_component_box(ax, 50, 5, 25, 12, "Cost Savings\n40% Reduction", IBM_COLORS['red'])
    
    # Add optimization flow
    for x in [16, 43, 70, 90.5]:
        add_arrow(ax, x, 85, x, 77)
    
    add_arrow(ax, 22.5, 45, 30, 35)
    add_arrow(ax, 52.5, 45, 52.5, 35)
    add_arrow(ax, 82.5, 45, 65, 35)
    
    add_arrow(ax, 32.5, 25, 32.5, 17)
    add_arrow(ax, 62.5, 25, 62.5, 17)
    
    plt.tight_layout()
    plt.savefig('diagrams/Figure_8.3.4_Performance_Optimization_Framework.png', 
                dpi=300, bbox_inches='tight', facecolor='white')
    plt.close()

def generate_diagram_5_operational_excellence():
    """Generate Figure 8.3.5: Operational Excellence Dashboard"""
    fig, ax = setup_figure("Figure 8.3.5: Operational Excellence Dashboard")
    
    # SRE practices
    add_component_box(ax, 5, 85, 20, 8, "SLO Management\nService Objectives", IBM_COLORS['blue'])
    add_component_box(ax, 30, 85, 20, 8, "Error Budgets\nReliability Targets", IBM_COLORS['blue'])
    add_component_box(ax, 55, 85, 20, 8, "Incident Response\nAutomated Workflows", IBM_COLORS['blue'])
    add_component_box(ax, 80, 85, 15, 8, "Postmortems\nLearning", IBM_COLORS['blue'])
    
    # Operational metrics
    add_component_box(ax, 5, 65, 18, 12, "Availability\n99.9% Uptime", IBM_COLORS['green'])
    add_component_box(ax, 28, 65, 18, 12, "Performance\nResponse Times", IBM_COLORS['green'])
    add_component_box(ax, 51, 65, 18, 12, "Reliability\nError Rates", IBM_COLORS['green'])
    add_component_box(ax, 74, 65, 21, 12, "Efficiency\nResource Utilization", IBM_COLORS['green'])
    
    # Dashboard views
    add_component_box(ax, 10, 45, 25, 10, "Executive Dashboard\nBusiness Metrics", IBM_COLORS['yellow'], 'black')
    add_component_box(ax, 40, 45, 25, 10, "Operations Dashboard\nTechnical Metrics", IBM_COLORS['yellow'], 'black')
    add_component_box(ax, 70, 45, 25, 10, "Team Dashboard\nPersonalized Views", IBM_COLORS['yellow'], 'black')
    
    # Continuous improvement
    add_component_box(ax, 15, 25, 30, 10, "Improvement Engine\nData-driven Optimization", IBM_COLORS['orange'])
    add_component_box(ax, 50, 25, 30, 10, "Feedback Loops\nContinuous Learning", IBM_COLORS['orange'])
    
    # Business outcomes
    add_component_box(ax, 10, 5, 35, 12, "Business Value\nOperational Excellence", IBM_COLORS['red'])
    add_component_box(ax, 50, 5, 35, 12, "Competitive Advantage\nReliability Leadership", IBM_COLORS['red'])
    
    # Add information flow
    for x in [15, 40, 65, 87.5]:
        add_arrow(ax, x, 85, x, 77)
    
    add_arrow(ax, 22.5, 45, 30, 35)
    add_arrow(ax, 52.5, 45, 52.5, 35)
    add_arrow(ax, 82.5, 45, 65, 35)
    
    add_arrow(ax, 27.5, 25, 27.5, 17)
    add_arrow(ax, 67.5, 25, 67.5, 17)
    
    # Add key metrics
    ax.text(5, 1, "Key Achievements: 99.9% reliability, 90% MTTR reduction, 95% automation", 
            fontsize=10, fontweight='bold', color=IBM_COLORS['dark_blue'])
    
    plt.tight_layout()
    plt.savefig('diagrams/Figure_8.3.5_Operational_Excellence_Dashboard.png', 
                dpi=300, bbox_inches='tight', facecolor='white')
    plt.close()

def main():
    """Generate all diagrams for Topic 8.3"""
    print("Generating Topic 8.3 Diagrams: Troubleshooting & Lifecycle Management")
    print("=" * 70)
    
    # Create diagrams directory if it doesn't exist
    os.makedirs('diagrams', exist_ok=True)
    
    # Generate all diagrams
    diagrams = [
        ("Figure 8.3.1", "Advanced Debugging Architecture", generate_diagram_1_debugging_architecture),
        ("Figure 8.3.2", "Performance Monitoring Stack", generate_diagram_2_monitoring_stack),
        ("Figure 8.3.3", "Self-Healing Infrastructure", generate_diagram_3_self_healing),
        ("Figure 8.3.4", "Performance Optimization Framework", generate_diagram_4_optimization_framework),
        ("Figure 8.3.5", "Operational Excellence Dashboard", generate_diagram_5_operational_excellence)
    ]
    
    for figure_num, title, generator_func in diagrams:
        print(f"Generating {figure_num}: {title}...")
        try:
            generator_func()
            print(f"✅ {figure_num} generated successfully")
        except Exception as e:
            print(f"❌ Error generating {figure_num}: {str(e)}")
    
    print("\n" + "=" * 70)
    print("All diagrams generated successfully!")
    print(f"Generated at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("Location: ./diagrams/")
    print("\nDiagram files:")
    for figure_num, title, _ in diagrams:
        filename = f"Figure_8.3.{figure_num.split('.')[2]}_{'_'.join(title.split())}.png"
        print(f"  - {filename}")

if __name__ == "__main__":
    main()
