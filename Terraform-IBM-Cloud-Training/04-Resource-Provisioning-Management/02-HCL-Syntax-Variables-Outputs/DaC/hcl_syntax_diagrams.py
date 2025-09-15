#!/usr/bin/env python3
"""
HCL Syntax and Configuration Diagrams Generator
==============================================

This script generates professional diagrams for HCL syntax, variables, and outputs
educational content, focusing on advanced configuration patterns and best practices.

Author: IBM Cloud Terraform Training Program
Version: 1.0.0
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, ConnectionPatch
import numpy as np
import os
from datetime import datetime

# IBM Brand Colors
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
    'purple': '#8a3ffc',
    'teal': '#009d9a'
}

def setup_diagram(figsize=(16, 12), title="", subtitle=""):
    """Set up a professional diagram with IBM branding."""
    fig, ax = plt.subplots(figsize=figsize, dpi=300)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')
    
    # Add title
    if title:
        ax.text(50, 95, title, fontsize=24, fontweight='bold', 
                ha='center', va='center', color=IBM_COLORS['dark_blue'])
    
    if subtitle:
        ax.text(50, 91, subtitle, fontsize=16, ha='center', va='center', 
                color=IBM_COLORS['gray'], style='italic')
    
    # Add IBM branding
    ax.text(2, 2, 'IBM Cloud Terraform Training', fontsize=10, 
            color=IBM_COLORS['gray'], alpha=0.7)
    ax.text(98, 2, f'Generated: {datetime.now().strftime("%Y-%m-%d")}', 
            fontsize=10, ha='right', color=IBM_COLORS['gray'], alpha=0.7)
    
    return fig, ax

def create_rounded_box(ax, x, y, width, height, text, color=IBM_COLORS['blue'], 
                      text_color=IBM_COLORS['white'], fontsize=12, alpha=1.0):
    """Create a rounded rectangle with text."""
    box = FancyBboxPatch(
        (x, y), width, height,
        boxstyle="round,pad=0.5",
        facecolor=color,
        edgecolor=IBM_COLORS['dark_blue'],
        linewidth=2,
        alpha=alpha
    )
    ax.add_patch(box)
    
    # Add text
    ax.text(x + width/2, y + height/2, text, fontsize=fontsize, 
            ha='center', va='center', color=text_color, fontweight='bold',
            wrap=True)
    
    return box

def create_arrow(ax, start_x, start_y, end_x, end_y, color=IBM_COLORS['gray']):
    """Create an arrow between two points."""
    arrow = patches.FancyArrowPatch(
        (start_x, start_y), (end_x, end_y),
        arrowstyle='->', mutation_scale=20,
        color=color, linewidth=2
    )
    ax.add_patch(arrow)
    return arrow

def diagram_1_hcl_syntax_overview():
    """Generate HCL Syntax Overview diagram."""
    fig, ax = setup_diagram(
        title="HCL Syntax Overview",
        subtitle="Core Language Elements and Structure"
    )
    
    # Main HCL components
    components = [
        {"name": "Blocks", "x": 10, "y": 75, "color": IBM_COLORS['blue']},
        {"name": "Arguments", "x": 35, "y": 75, "color": IBM_COLORS['green']},
        {"name": "Expressions", "x": 60, "y": 75, "color": IBM_COLORS['orange']},
        {"name": "Comments", "x": 85, "y": 75, "color": IBM_COLORS['purple']}
    ]
    
    for comp in components:
        create_rounded_box(ax, comp['x']-5, comp['y']-3, 10, 6, 
                          comp['name'], comp['color'])
    
    # Block types
    block_types = [
        {"name": "resource", "x": 5, "y": 60},
        {"name": "variable", "x": 5, "y": 50},
        {"name": "output", "x": 5, "y": 40},
        {"name": "locals", "x": 5, "y": 30},
        {"name": "data", "x": 5, "y": 20}
    ]
    
    for block in block_types:
        create_rounded_box(ax, block['x'], block['y'], 12, 5, 
                          block['name'], IBM_COLORS['light_blue'], 
                          IBM_COLORS['dark_blue'], 10)
        create_arrow(ax, 15, 72, block['x']+6, block['y']+5)
    
    # Argument types
    arg_types = [
        {"name": "String", "x": 30, "y": 60},
        {"name": "Number", "x": 30, "y": 50},
        {"name": "Boolean", "x": 30, "y": 40},
        {"name": "List", "x": 30, "y": 30},
        {"name": "Map", "x": 30, "y": 20}
    ]
    
    for arg in arg_types:
        create_rounded_box(ax, arg['x'], arg['y'], 12, 5, 
                          arg['name'], IBM_COLORS['light_gray'], 
                          IBM_COLORS['dark_blue'], 10)
        create_arrow(ax, 40, 72, arg['x']+6, arg['y']+5)
    
    # Expression types
    expr_types = [
        {"name": "Functions", "x": 55, "y": 60},
        {"name": "Conditionals", "x": 55, "y": 50},
        {"name": "For Loops", "x": 55, "y": 40},
        {"name": "Splat", "x": 55, "y": 30},
        {"name": "References", "x": 55, "y": 20}
    ]
    
    for expr in expr_types:
        create_rounded_box(ax, expr['x'], expr['y'], 12, 5, 
                          expr['name'], IBM_COLORS['light_gray'], 
                          IBM_COLORS['dark_blue'], 10)
        create_arrow(ax, 65, 72, expr['x']+6, expr['y']+5)
    
    # Comment types
    comment_types = [
        {"name": "# Single Line", "x": 80, "y": 60},
        {"name": "/* Multi Line */", "x": 80, "y": 50}
    ]
    
    for comment in comment_types:
        create_rounded_box(ax, comment['x'], comment['y'], 12, 5, 
                          comment['name'], IBM_COLORS['light_gray'], 
                          IBM_COLORS['dark_blue'], 9)
        create_arrow(ax, 90, 72, comment['x']+6, comment['y']+5)
    
    # Add example code box
    code_example = '''variable "example" {
  description = "Example variable"
  type        = string
  default     = "hello"
  
  validation {
    condition = length(var.example) > 0
    error_message = "Must not be empty"
  }
}'''
    
    ax.text(50, 10, code_example, fontsize=10, ha='center', va='center',
            bbox=dict(boxstyle="round,pad=1", facecolor=IBM_COLORS['light_gray'],
                     edgecolor=IBM_COLORS['gray']), fontfamily='monospace')
    
    plt.tight_layout()
    return fig

def diagram_2_variable_patterns():
    """Generate Variable Patterns and Validation diagram."""
    fig, ax = setup_diagram(
        title="Advanced Variable Patterns",
        subtitle="Types, Validation, and Enterprise Patterns"
    )
    
    # Variable type hierarchy
    ax.text(50, 85, "Variable Type Hierarchy", fontsize=18, fontweight='bold',
            ha='center', color=IBM_COLORS['dark_blue'])
    
    # Basic types
    basic_types = [
        {"name": "string", "x": 10, "y": 75, "color": IBM_COLORS['blue']},
        {"name": "number", "x": 25, "y": 75, "color": IBM_COLORS['blue']},
        {"name": "bool", "x": 40, "y": 75, "color": IBM_COLORS['blue']}
    ]
    
    for btype in basic_types:
        create_rounded_box(ax, btype['x'], btype['y'], 10, 5, 
                          btype['name'], btype['color'])
    
    # Complex types
    complex_types = [
        {"name": "list(type)", "x": 60, "y": 75, "color": IBM_COLORS['green']},
        {"name": "map(type)", "x": 75, "y": 75, "color": IBM_COLORS['green']},
        {"name": "object({...})", "x": 67.5, "y": 65, "color": IBM_COLORS['orange']}
    ]
    
    for ctype in complex_types:
        create_rounded_box(ax, ctype['x'], ctype['y'], 12, 5, 
                          ctype['name'], ctype['color'])
    
    # Validation patterns
    ax.text(25, 55, "Validation Patterns", fontsize=16, fontweight='bold',
            ha='center', color=IBM_COLORS['dark_blue'])
    
    validation_examples = [
        {"name": "Format\nValidation", "x": 5, "y": 45, "desc": "regex(), can()"},
        {"name": "Range\nValidation", "x": 20, "y": 45, "desc": ">, <, >=, <="},
        {"name": "List\nValidation", "x": 35, "y": 45, "desc": "contains(), alltrue()"},
        {"name": "Custom\nValidation", "x": 50, "y": 45, "desc": "Complex conditions"}
    ]
    
    for val in validation_examples:
        create_rounded_box(ax, val['x'], val['y'], 12, 8, 
                          val['name'], IBM_COLORS['purple'])
        ax.text(val['x']+6, val['y']-3, val['desc'], fontsize=9, 
                ha='center', color=IBM_COLORS['gray'])
    
    # Enterprise patterns
    ax.text(75, 55, "Enterprise Patterns", fontsize=16, fontweight='bold',
            ha='center', color=IBM_COLORS['dark_blue'])
    
    enterprise_patterns = [
        {"name": "Multi-Environment\nConfigurations", "x": 65, "y": 45},
        {"name": "Tenant\nIsolation", "x": 80, "y": 45},
        {"name": "Compliance\nValidation", "x": 65, "y": 35},
        {"name": "Cost\nOptimization", "x": 80, "y": 35}
    ]
    
    for pattern in enterprise_patterns:
        create_rounded_box(ax, pattern['x'], pattern['y'], 12, 8, 
                          pattern['name'], IBM_COLORS['teal'])
    
    # Variable precedence flow
    ax.text(50, 25, "Variable Precedence (Highest to Lowest)", fontsize=14, 
            fontweight='bold', ha='center', color=IBM_COLORS['dark_blue'])
    
    precedence_items = [
        "Command Line (-var)",
        "Variable Files (-var-file)",
        "Environment Variables (TF_VAR_)",
        "terraform.tfvars",
        "*.auto.tfvars",
        "Default Values"
    ]
    
    for i, item in enumerate(precedence_items):
        y_pos = 18 - i * 2
        create_rounded_box(ax, 20 + i * 10, y_pos, 10, 3, 
                          f"{i+1}", IBM_COLORS['gray'])
        ax.text(25 + i * 10, y_pos - 2, item, fontsize=9, 
                ha='center', color=IBM_COLORS['dark_blue'])
        
        if i < len(precedence_items) - 1:
            create_arrow(ax, 30 + i * 10, y_pos + 1.5, 
                        20 + (i + 1) * 10, y_pos - 0.5)
    
    plt.tight_layout()
    return fig

def diagram_3_output_strategies():
    """Generate Output Strategies and Module Integration diagram."""
    fig, ax = setup_diagram(
        title="Output Strategies and Module Integration",
        subtitle="Cross-Module References and Data Flow Patterns"
    )
    
    # Module architecture
    modules = [
        {"name": "Network\nModule", "x": 10, "y": 70, "color": IBM_COLORS['blue']},
        {"name": "Compute\nModule", "x": 40, "y": 70, "color": IBM_COLORS['green']},
        {"name": "Security\nModule", "x": 70, "y": 70, "color": IBM_COLORS['orange']},
        {"name": "Storage\nModule", "x": 25, "y": 50, "color": IBM_COLORS['purple']},
        {"name": "Monitoring\nModule", "x": 55, "y": 50, "color": IBM_COLORS['teal']}
    ]
    
    for module in modules:
        create_rounded_box(ax, module['x'], module['y'], 15, 10, 
                          module['name'], module['color'])
    
    # Output types
    output_types = [
        {"name": "Resource IDs", "x": 5, "y": 35, "color": IBM_COLORS['light_blue']},
        {"name": "Configuration\nData", "x": 25, "y": 35, "color": IBM_COLORS['light_blue']},
        {"name": "Computed\nValues", "x": 45, "y": 35, "color": IBM_COLORS['light_blue']},
        {"name": "Sensitive\nData", "x": 65, "y": 35, "color": IBM_COLORS['red']},
        {"name": "Metadata", "x": 85, "y": 35, "color": IBM_COLORS['light_blue']}
    ]
    
    for output in output_types:
        create_rounded_box(ax, output['x'], output['y'], 12, 8, 
                          output['name'], output['color'])
    
    # Data flow arrows
    connections = [
        # Network to Compute
        {"from": (17.5, 70), "to": (40, 75)},
        # Network to Security  
        {"from": (25, 75), "to": (70, 75)},
        # Compute to Storage
        {"from": (47.5, 70), "to": (32.5, 60)},
        # Security to Monitoring
        {"from": (77.5, 70), "to": (62.5, 60)},
        # Storage to Monitoring
        {"from": (40, 55), "to": (55, 55)}
    ]
    
    for conn in connections:
        create_arrow(ax, conn['from'][0], conn['from'][1], 
                    conn['to'][0], conn['to'][1], IBM_COLORS['gray'])
    
    # Output patterns
    ax.text(50, 25, "Output Design Patterns", fontsize=16, fontweight='bold',
            ha='center', color=IBM_COLORS['dark_blue'])
    
    patterns = [
        {"name": "Structured\nOutputs", "x": 10, "y": 15, "desc": "Organized data"},
        {"name": "Conditional\nOutputs", "x": 30, "y": 15, "desc": "Environment-based"},
        {"name": "Computed\nOutputs", "x": 50, "y": 15, "desc": "Dynamic values"},
        {"name": "Sensitive\nHandling", "x": 70, "y": 15, "desc": "Security focus"}
    ]
    
    for pattern in patterns:
        create_rounded_box(ax, pattern['x'], pattern['y'], 15, 6, 
                          pattern['name'], IBM_COLORS['gray'])
        ax.text(pattern['x'] + 7.5, pattern['y'] - 3, pattern['desc'], 
                fontsize=9, ha='center', color=IBM_COLORS['dark_blue'])
    
    # Best practices box
    best_practices = [
        "• Use descriptive output names",
        "• Group related outputs logically", 
        "• Mark sensitive outputs appropriately",
        "• Include comprehensive descriptions",
        "• Design for module integration"
    ]
    
    ax.text(50, 5, "Output Best Practices:\n" + "\n".join(best_practices), 
            fontsize=10, ha='center', va='center',
            bbox=dict(boxstyle="round,pad=1", facecolor=IBM_COLORS['light_gray'],
                     edgecolor=IBM_COLORS['gray']))
    
    plt.tight_layout()
    return fig

def diagram_4_local_values_optimization():
    """Generate Local Values and Performance Optimization diagram."""
    fig, ax = setup_diagram(
        title="Local Values and Performance Optimization",
        subtitle="Computed Expressions and Efficiency Patterns"
    )
    
    # Local values workflow
    ax.text(50, 85, "Local Values Computation Flow", fontsize=18, fontweight='bold',
            ha='center', color=IBM_COLORS['dark_blue'])
    
    # Input sources
    inputs = [
        {"name": "Variables", "x": 5, "y": 75, "color": IBM_COLORS['blue']},
        {"name": "Data Sources", "x": 20, "y": 75, "color": IBM_COLORS['green']},
        {"name": "Resource\nAttributes", "x": 35, "y": 75, "color": IBM_COLORS['orange']}
    ]
    
    for inp in inputs:
        create_rounded_box(ax, inp['x'], inp['y'], 12, 8, 
                          inp['name'], inp['color'])
    
    # Local computation engine
    create_rounded_box(ax, 55, 70, 20, 15, 
                      "Local Values\nComputation Engine", 
                      IBM_COLORS['purple'], fontsize=14)
    
    # Connect inputs to engine
    for inp in inputs:
        create_arrow(ax, inp['x'] + 12, inp['y'] + 4, 55, 77.5)
    
    # Output destinations
    outputs = [
        {"name": "Resources", "x": 85, "y": 80, "color": IBM_COLORS['blue']},
        {"name": "Outputs", "x": 85, "y": 70, "color": IBM_COLORS['green']},
        {"name": "Other Locals", "x": 85, "y": 60, "color": IBM_COLORS['orange']}
    ]
    
    for out in outputs:
        create_rounded_box(ax, out['x'], out['y'], 12, 6, 
                          out['name'], out['color'])
        create_arrow(ax, 75, 77.5, out['x'], out['y'] + 3)
    
    # Optimization patterns
    ax.text(25, 55, "Performance Optimization Patterns", fontsize=16, 
            fontweight='bold', ha='center', color=IBM_COLORS['dark_blue'])
    
    optimization_patterns = [
        {"name": "Pre-compute\nFrequent Values", "x": 5, "y": 45, "benefit": "Reduce CPU"},
        {"name": "Minimize\nString Operations", "x": 25, "y": 45, "benefit": "Memory Efficient"},
        {"name": "Use Efficient\nData Structures", "x": 45, "y": 45, "benefit": "Fast Lookup"},
        {"name": "Cache Complex\nCalculations", "x": 65, "y": 45, "benefit": "Avoid Recompute"}
    ]
    
    for pattern in optimization_patterns:
        create_rounded_box(ax, pattern['x'], pattern['y'], 15, 8, 
                          pattern['name'], IBM_COLORS['teal'])
        ax.text(pattern['x'] + 7.5, pattern['y'] - 3, pattern['benefit'], 
                fontsize=9, ha='center', color=IBM_COLORS['gray'])
    
    # Common local patterns
    ax.text(75, 55, "Common Patterns", fontsize=16, fontweight='bold',
            ha='center', color=IBM_COLORS['dark_blue'])
    
    common_patterns = [
        {"name": "Naming\nConventions", "x": 85, "y": 45},
        {"name": "Tag\nGeneration", "x": 85, "y": 35},
        {"name": "CIDR\nCalculations", "x": 85, "y": 25},
        {"name": "Conditional\nLogic", "x": 85, "y": 15}
    ]
    
    for pattern in common_patterns:
        create_rounded_box(ax, pattern['x'], pattern['y'], 12, 6, 
                          pattern['name'], IBM_COLORS['gray'])
    
    # Performance metrics
    metrics_text = """Performance Metrics:
• Plan Generation: < 30 seconds
• Validation: < 5 seconds  
• Memory Usage: < 512MB
• Configuration Complexity: Manageable"""
    
    ax.text(25, 25, metrics_text, fontsize=11, ha='left', va='top',
            bbox=dict(boxstyle="round,pad=1", facecolor=IBM_COLORS['light_gray'],
                     edgecolor=IBM_COLORS['gray']))
    
    # Anti-patterns
    antipatterns_text = """Avoid These Anti-Patterns:
• Complex nested expressions
• Repeated calculations
• Inefficient string concatenation
• Circular dependencies"""
    
    ax.text(25, 10, antipatterns_text, fontsize=11, ha='left', va='top',
            bbox=dict(boxstyle="round,pad=1", facecolor='#ffe6e6',
                     edgecolor=IBM_COLORS['red']))
    
    plt.tight_layout()
    return fig

def diagram_5_enterprise_hcl_governance():
    """Generate Enterprise HCL Governance and Standards diagram."""
    fig, ax = setup_diagram(
        title="Enterprise HCL Governance and Standards",
        subtitle="Code Quality, Compliance, and Team Collaboration"
    )
    
    # Governance framework
    ax.text(50, 90, "HCL Governance Framework", fontsize=18, fontweight='bold',
            ha='center', color=IBM_COLORS['dark_blue'])
    
    # Governance pillars
    pillars = [
        {"name": "Code\nStandards", "x": 10, "y": 75, "color": IBM_COLORS['blue']},
        {"name": "Security\nCompliance", "x": 30, "y": 75, "color": IBM_COLORS['red']},
        {"name": "Performance\nOptimization", "x": 50, "y": 75, "color": IBM_COLORS['green']},
        {"name": "Team\nCollaboration", "x": 70, "y": 75, "color": IBM_COLORS['purple']}
    ]
    
    for pillar in pillars:
        create_rounded_box(ax, pillar['x'], pillar['y'], 15, 10, 
                          pillar['name'], pillar['color'])
    
    # Code standards details
    code_standards = [
        {"name": "Naming\nConventions", "x": 5, "y": 60},
        {"name": "File\nOrganization", "x": 5, "y": 50},
        {"name": "Documentation\nStandards", "x": 5, "y": 40}
    ]
    
    for standard in code_standards:
        create_rounded_box(ax, standard['x'], standard['y'], 12, 6, 
                          standard['name'], IBM_COLORS['light_blue'])
        create_arrow(ax, 17.5, 75, standard['x'] + 6, standard['y'] + 6)
    
    # Security compliance details
    security_items = [
        {"name": "Sensitive Data\nHandling", "x": 25, "y": 60},
        {"name": "Access\nControls", "x": 25, "y": 50},
        {"name": "Audit\nTrails", "x": 25, "y": 40}
    ]
    
    for item in security_items:
        create_rounded_box(ax, item['x'], item['y'], 12, 6, 
                          item['name'], '#ffcccc')
        create_arrow(ax, 37.5, 75, item['x'] + 6, item['y'] + 6)
    
    # Performance optimization details
    perf_items = [
        {"name": "Resource\nEfficiency", "x": 45, "y": 60},
        {"name": "Plan\nOptimization", "x": 45, "y": 50},
        {"name": "State\nManagement", "x": 45, "y": 40}
    ]
    
    for item in perf_items:
        create_rounded_box(ax, item['x'], item['y'], 12, 6, 
                          item['name'], '#ccffcc')
        create_arrow(ax, 57.5, 75, item['x'] + 6, item['y'] + 6)
    
    # Team collaboration details
    collab_items = [
        {"name": "Code\nReviews", "x": 65, "y": 60},
        {"name": "Shared\nModules", "x": 65, "y": 50},
        {"name": "Knowledge\nSharing", "x": 65, "y": 40}
    ]
    
    for item in collab_items:
        create_rounded_box(ax, item['x'], item['y'], 12, 6, 
                          item['name'], '#e6ccff')
        create_arrow(ax, 77.5, 75, item['x'] + 6, item['y'] + 6)
    
    # Quality gates
    ax.text(50, 30, "Quality Gates and Validation", fontsize=16, fontweight='bold',
            ha='center', color=IBM_COLORS['dark_blue'])
    
    quality_gates = [
        {"name": "terraform fmt", "x": 10, "y": 20, "desc": "Format check"},
        {"name": "terraform validate", "x": 30, "y": 20, "desc": "Syntax validation"},
        {"name": "tfsec", "x": 50, "y": 20, "desc": "Security scan"},
        {"name": "checkov", "x": 70, "y": 20, "desc": "Policy check"}
    ]
    
    for gate in quality_gates:
        create_rounded_box(ax, gate['x'], gate['y'], 15, 6, 
                          gate['name'], IBM_COLORS['teal'])
        ax.text(gate['x'] + 7.5, gate['y'] - 3, gate['desc'], 
                fontsize=9, ha='center', color=IBM_COLORS['gray'])
    
    # Connect quality gates
    for i in range(len(quality_gates) - 1):
        create_arrow(ax, quality_gates[i]['x'] + 15, quality_gates[i]['y'] + 3,
                    quality_gates[i+1]['x'], quality_gates[i+1]['y'] + 3)
    
    # Benefits box
    benefits_text = """Enterprise Benefits:
• 85% reduction in configuration errors
• 70% improvement in code maintainability  
• 60% faster development cycles
• 80% better team collaboration
• 99.5% configuration reliability"""
    
    ax.text(50, 8, benefits_text, fontsize=11, ha='center', va='center',
            bbox=dict(boxstyle="round,pad=1", facecolor=IBM_COLORS['light_gray'],
                     edgecolor=IBM_COLORS['gray']))
    
    plt.tight_layout()
    return fig

def main():
    """Generate all HCL syntax and configuration diagrams."""
    print("🎨 Generating HCL Syntax and Configuration Diagrams...")
    
    # Create output directory
    output_dir = "generated_diagrams"
    os.makedirs(output_dir, exist_ok=True)
    
    # Generate all diagrams
    diagrams = [
        ("hcl_syntax_overview", diagram_1_hcl_syntax_overview),
        ("variable_patterns", diagram_2_variable_patterns),
        ("output_strategies", diagram_3_output_strategies),
        ("local_values_optimization", diagram_4_local_values_optimization),
        ("enterprise_hcl_governance", diagram_5_enterprise_hcl_governance)
    ]
    
    total_size = 0
    
    for name, diagram_func in diagrams:
        print(f"  📊 Generating {name}...")
        fig = diagram_func()
        
        # Save diagram
        filename = f"{output_dir}/{name}.png"
        fig.savefig(filename, dpi=300, bbox_inches='tight', 
                   facecolor='white', edgecolor='none')
        plt.close(fig)
        
        # Get file size
        size = os.path.getsize(filename)
        total_size += size
        print(f"     ✅ Saved {filename} ({size/1024:.1f} KB)")
    
    print(f"\n🎉 Successfully generated {len(diagrams)} diagrams!")
    print(f"📁 Total size: {total_size/1024/1024:.1f} MB")
    print(f"📍 Location: {output_dir}/")
    print(f"🎯 Resolution: 300 DPI (print quality)")
    print(f"🎨 Style: IBM Brand Colors")

if __name__ == "__main__":
    main()
