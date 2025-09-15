#!/usr/bin/env python3
"""
Provider Configuration and Authentication - Diagram as Code (DaC)
Generates 5 professional diagrams for Terraform provider configuration concepts.

Diagrams:
1. provider_architecture.png - Comprehensive provider architecture overview
2. ibm_provider_config.png - Detailed IBM Cloud provider configuration
3. authentication_security.png - Authentication security framework
4. multi_provider_setup.png - Multi-provider and multi-environment setup
5. provider_troubleshooting.png - Troubleshooting and diagnostic procedures

Author: IBM Cloud Terraform Training Program
Created: 2024-01-20
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
import seaborn as sns
from matplotlib.patches import FancyBboxPatch, ConnectionPatch, Circle, Arrow, Rectangle
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
IBM_CYAN = '#1192E8'

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

def create_security_shield(ax, x, y, size, color=IBM_GREEN):
    """Create a security shield icon."""
    # Shield shape
    shield_points = np.array([
        [x, y + size*0.8],
        [x + size*0.3, y + size],
        [x + size*0.7, y + size],
        [x + size, y + size*0.8],
        [x + size, y + size*0.3],
        [x + size*0.5, y],
        [x, y + size*0.3]
    ])
    
    shield = patches.Polygon(shield_points, closed=True, 
                           facecolor=color, edgecolor=IBM_GRAY, linewidth=2)
    ax.add_patch(shield)
    
    # Add checkmark
    ax.text(x + size/2, y + size/2, '✓', ha='center', va='center',
            fontsize=size*20, color=IBM_WHITE, weight='bold')

def diagram_1_provider_architecture():
    """Generate comprehensive provider architecture overview diagram."""
    fig, ax = setup_figure("Provider Architecture - Terraform and IBM Cloud Integration")
    
    # Architecture title
    create_rounded_box(ax, 1, 8.5, 8, 1, 
                      "Terraform Provider Architecture - IBM Cloud Integration Framework", 
                      IBM_BLUE, IBM_WHITE, 14)
    
    # Terraform Core
    create_rounded_box(ax, 1, 6.5, 2, 1.5, 
                      "Terraform Core\n\n• Configuration Parser\n• State Management\n• Execution Engine\n• Dependency Graph", 
                      IBM_DARK_BLUE, IBM_WHITE, 9)
    
    # Provider Layer
    create_rounded_box(ax, 4, 6.5, 2, 1.5, 
                      "Provider Layer\n\n• IBM Cloud Provider\n• Resource Mapping\n• API Translation\n• State Sync", 
                      IBM_PURPLE, IBM_WHITE, 9)
    
    # IBM Cloud APIs
    create_rounded_box(ax, 7, 6.5, 2, 1.5, 
                      "IBM Cloud APIs\n\n• VPC Service\n• IAM Service\n• Resource Manager\n• Activity Tracker", 
                      IBM_CYAN, IBM_WHITE, 9)
    
    # Authentication Layer
    create_rounded_box(ax, 1, 4.5, 8, 1.5, 
                      "Authentication & Security Layer\n\nAPI Keys • Service IDs • Trusted Profiles • IAM Integration\nEncryption • Access Control • Audit Logging • Compliance", 
                      IBM_GREEN, IBM_WHITE, 10)
    
    # Configuration Management
    create_rounded_box(ax, 0.5, 2.5, 3, 1.5, 
                      "Configuration Management\n\n• Provider Blocks\n• Version Constraints\n• Feature Flags\n• Performance Tuning", 
                      IBM_ORANGE, IBM_WHITE, 9)
    
    # Multi-Environment Support
    create_rounded_box(ax, 3.8, 2.5, 3, 1.5, 
                      "Multi-Environment\n\n• Provider Aliases\n• Regional Config\n• Environment Variables\n• CI/CD Integration", 
                      IBM_LIGHT_BLUE, IBM_WHITE, 9)
    
    # Monitoring & Diagnostics
    create_rounded_box(ax, 7.1, 2.5, 2.4, 1.5, 
                      "Monitoring\n\n• Debug Logging\n• Performance Metrics\n• Error Tracking\n• Health Checks", 
                      IBM_RED, IBM_WHITE, 9)
    
    # Enterprise Features
    create_rounded_box(ax, 2, 0.5, 6, 1.5, 
                      "Enterprise Features\n\nPrivate Endpoints • Network Isolation • Compliance Frameworks\nDisaster Recovery • High Availability • Cost Optimization", 
                      IBM_LIGHT_GRAY, IBM_GRAY, 10)
    
    # Add arrows showing data flow
    create_arrow(ax, (3, 7.25), (4, 7.25), IBM_BLUE)
    create_arrow(ax, (6, 7.25), (7, 7.25), IBM_BLUE)
    create_arrow(ax, (5, 6.5), (5, 6), IBM_GREEN)
    
    plt.tight_layout()
    plt.savefig('generated_diagrams/provider_architecture.png', dpi=300, bbox_inches='tight')
    plt.close()

def diagram_2_ibm_provider_config():
    """Generate detailed IBM Cloud provider configuration diagram."""
    fig, ax = setup_figure("IBM Cloud Provider Configuration - Authentication and Settings")
    
    # Configuration title
    create_rounded_box(ax, 1, 8.5, 8, 1, 
                      "IBM Cloud Provider Configuration - Comprehensive Setup Guide", 
                      IBM_BLUE, IBM_WHITE, 14)
    
    # Provider block structure
    create_rounded_box(ax, 0.5, 7, 4, 1.2, 
                      "Provider Block Structure\n\nterraform { required_providers { ibm = { ... } } }\nprovider \"ibm\" { ... }", 
                      IBM_DARK_BLUE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 5, 7, 4, 1.2, 
                      "Version Constraints\n\nsource = \"IBM-Cloud/ibm\"\nversion = \"~> 1.58.0\"", 
                      IBM_PURPLE, IBM_WHITE, 9)
    
    # Authentication methods
    create_rounded_box(ax, 0.5, 5.5, 2.2, 1.2, 
                      "API Key Auth\n\nibmcloud_api_key\nEnvironment: IC_API_KEY\nMost Common", 
                      IBM_GREEN, IBM_WHITE, 9)
    
    create_rounded_box(ax, 2.9, 5.5, 2.2, 1.2, 
                      "Service ID Auth\n\niam_client_id\niam_client_secret\nEnterprise Use", 
                      IBM_ORANGE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 5.3, 5.5, 2.2, 1.2, 
                      "Trusted Profile\n\niam_trusted_profile_id\nZero-Trust Security\nAdvanced", 
                      IBM_CYAN, IBM_WHITE, 9)
    
    create_rounded_box(ax, 7.6, 5.5, 1.9, 1.2, 
                      "External Secrets\n\nVault Integration\nAWS Secrets\nEnterprise", 
                      IBM_RED, IBM_WHITE, 9)
    
    # Configuration options
    create_rounded_box(ax, 0.5, 3.8, 4.5, 1.5, 
                      "Regional & Performance Configuration\n\nregion • zone • resource_group_id\nibmcloud_timeout • max_retries • retry_delay\nendpoint_type • visibility", 
                      IBM_LIGHT_BLUE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 5.2, 3.8, 4.3, 1.5, 
                      "Enterprise & Debug Settings\n\ncustom_headers • ibmcloud_trace\nrate_limit • connection_pooling\nfeature_flags • experimental", 
                      IBM_LIGHT_GRAY, IBM_GRAY, 9)
    
    # Best practices
    create_rounded_box(ax, 0.5, 2, 9, 1.5, 
                      "Security & Performance Best Practices\n\nUse environment variables for credentials • Implement proper IAM permissions • Enable retry logic\nOptimize timeouts for region • Use private endpoints in production • Enable audit logging", 
                      IBM_GREEN, IBM_WHITE, 10)
    
    # Common patterns
    create_rounded_box(ax, 2, 0.3, 6, 1.5, 
                      "Common Configuration Patterns\n\nDevelopment: Public endpoints, debug enabled, relaxed timeouts\nProduction: Private endpoints, no debug, conservative settings", 
                      IBM_ORANGE, IBM_WHITE, 10)
    
    plt.tight_layout()
    plt.savefig('generated_diagrams/ibm_provider_config.png', dpi=300, bbox_inches='tight')
    plt.close()

def diagram_3_authentication_security():
    """Generate authentication security framework diagram."""
    fig, ax = setup_figure("Authentication Security Framework - Credential Management")
    
    # Security title
    create_rounded_box(ax, 1, 8.5, 8, 1, 
                      "Authentication Security Framework - Enterprise Credential Management", 
                      IBM_GREEN, IBM_WHITE, 14)
    
    # Security hierarchy
    create_rounded_box(ax, 0.5, 7, 2, 1.2, 
                      "Environment Variables\n\nHighest Security\nIC_API_KEY\nNo file storage", 
                      IBM_GREEN, IBM_WHITE, 9)
    
    create_rounded_box(ax, 2.8, 7, 2, 1.2, 
                      "External Secrets\n\nVault/AWS Secrets\nRotation Support\nAudit Trails", 
                      IBM_DARK_BLUE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 5.1, 7, 2, 1.2, 
                      "Service IDs\n\nEnterprise Standard\nAutomatic Rotation\nRole-based Access", 
                      IBM_PURPLE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 7.4, 7, 2.1, 1.2, 
                      "Trusted Profiles\n\nZero-Trust Model\nNo Stored Secrets\nDynamic Access", 
                      IBM_CYAN, IBM_WHITE, 9)
    
    # Security shields for each method
    create_security_shield(ax, 1.2, 6.2, 0.3, IBM_GREEN)
    create_security_shield(ax, 3.5, 6.2, 0.3, IBM_DARK_BLUE)
    create_security_shield(ax, 5.8, 6.2, 0.3, IBM_PURPLE)
    create_security_shield(ax, 8.1, 6.2, 0.3, IBM_CYAN)
    
    # IAM Integration
    create_rounded_box(ax, 1, 5, 8, 1.5, 
                      "IAM Integration & Access Control\n\nRole-based Permissions • Resource-level Access • Time-based Controls\nCompliance Frameworks • Audit Logging • Activity Tracking", 
                      IBM_ORANGE, IBM_WHITE, 10)
    
    # Security controls
    create_rounded_box(ax, 0.5, 3, 3, 1.5, 
                      "Security Controls\n\n• Credential Rotation\n• Access Monitoring\n• Anomaly Detection\n• Compliance Reporting", 
                      IBM_RED, IBM_WHITE, 9)
    
    create_rounded_box(ax, 3.8, 3, 3, 1.5, 
                      "Network Security\n\n• Private Endpoints\n• VPC Isolation\n• Firewall Rules\n• Encrypted Transit", 
                      IBM_DARK_BLUE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 7.1, 3, 2.4, 1.5, 
                      "Audit & Compliance\n\n• Activity Tracker\n• Security Events\n• Compliance Reports\n• Risk Assessment", 
                      IBM_PURPLE, IBM_WHITE, 9)
    
    # Best practices
    create_rounded_box(ax, 1.5, 1, 7, 1.5, 
                      "Security Best Practices\n\nNever commit credentials • Rotate regularly • Use least privilege • Monitor access\nImplement MFA • Enable logging • Regular security reviews", 
                      IBM_LIGHT_GRAY, IBM_GRAY, 10)
    
    plt.tight_layout()
    plt.savefig('generated_diagrams/authentication_security.png', dpi=300, bbox_inches='tight')
    plt.close()

def diagram_4_multi_provider_setup():
    """Generate multi-provider and multi-environment setup diagram."""
    fig, ax = setup_figure("Multi-Provider Setup - Environment and Regional Configuration")
    
    # Setup title
    create_rounded_box(ax, 1, 8.5, 8, 1, 
                      "Multi-Provider Setup - Enterprise Environment Management", 
                      IBM_PURPLE, IBM_WHITE, 14)
    
    # Environment configurations
    create_rounded_box(ax, 0.5, 7, 2.8, 1.2, 
                      "Development Environment\n\nPublic endpoints\nDebug enabled\nRelaxed timeouts\nSingle region", 
                      IBM_GREEN, IBM_WHITE, 9)
    
    create_rounded_box(ax, 3.6, 7, 2.8, 1.2, 
                      "Staging Environment\n\nPublic endpoints\nLimited debug\nModerate timeouts\nMulti-region", 
                      IBM_ORANGE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 6.7, 7, 2.8, 1.2, 
                      "Production Environment\n\nPrivate endpoints\nNo debug\nConservative settings\nGlobal deployment", 
                      IBM_RED, IBM_WHITE, 9)
    
    # Regional providers
    create_rounded_box(ax, 0.5, 5.5, 2.2, 1.2, 
                      "US South Provider\n\nalias = \"us_south\"\nOptimized latency\nPrimary region", 
                      IBM_BLUE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 2.9, 5.5, 2.2, 1.2, 
                      "EU GB Provider\n\nalias = \"eu_gb\"\nGDPR compliance\nSecondary region", 
                      IBM_DARK_BLUE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 5.3, 5.5, 2.2, 1.2, 
                      "Asia Pacific\n\nalias = \"jp_tok\"\nHigh latency config\nTertiary region", 
                      IBM_CYAN, IBM_WHITE, 9)
    
    create_rounded_box(ax, 7.6, 5.5, 1.9, 1.2, 
                      "Edge Locations\n\nMultiple aliases\nEdge computing\nLocal processing", 
                      IBM_PURPLE, IBM_WHITE, 9)
    
    # Supporting providers
    create_rounded_box(ax, 0.5, 3.8, 4.5, 1.5, 
                      "Supporting Provider Ecosystem\n\nRandom • Time • Local • HTTP • TLS\nVault • External APIs • Custom Providers\nDependency Management", 
                      IBM_LIGHT_BLUE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 5.2, 3.8, 4.3, 1.5, 
                      "Provider Orchestration\n\nAlias Management • Version Constraints\nFeature Flags • Performance Tuning\nError Handling • Retry Logic", 
                      IBM_LIGHT_GRAY, IBM_GRAY, 9)
    
    # Integration patterns
    create_rounded_box(ax, 1, 2, 8, 1.5, 
                      "Enterprise Integration Patterns\n\nCI/CD Pipeline Integration • GitOps Workflows • Infrastructure as Code\nMulti-Cloud Strategies • Hybrid Deployments • Disaster Recovery", 
                      IBM_ORANGE, IBM_WHITE, 10)
    
    # Management strategies
    create_rounded_box(ax, 2.5, 0.3, 5, 1.5, 
                      "Provider Management Strategies\n\nCentralized Configuration • Environment Promotion\nAutomated Testing • Compliance Validation", 
                      IBM_GREEN, IBM_WHITE, 10)
    
    # Add connection arrows
    create_arrow(ax, (1.9, 7), (1.6, 6.7), IBM_GRAY)
    create_arrow(ax, (5, 7), (4.0, 6.7), IBM_GRAY)
    create_arrow(ax, (8.1, 7), (6.4, 6.7), IBM_GRAY)
    
    plt.tight_layout()
    plt.savefig('generated_diagrams/multi_provider_setup.png', dpi=300, bbox_inches='tight')
    plt.close()

def diagram_5_provider_troubleshooting():
    """Generate provider troubleshooting and diagnostic procedures diagram."""
    fig, ax = setup_figure("Provider Troubleshooting - Diagnostic and Resolution Framework")
    
    # Troubleshooting title
    create_rounded_box(ax, 1, 8.5, 8, 1, 
                      "Provider Troubleshooting - Comprehensive Diagnostic Framework", 
                      IBM_RED, IBM_WHITE, 14)
    
    # Diagnostic categories
    create_rounded_box(ax, 0.5, 7, 2.2, 1.2, 
                      "Authentication Issues\n\n• Invalid API keys\n• Permission errors\n• Token expiration\n• IAM misconfig", 
                      IBM_RED, IBM_WHITE, 9)
    
    create_rounded_box(ax, 2.9, 7, 2.2, 1.2, 
                      "Configuration Errors\n\n• Version conflicts\n• Invalid regions\n• Missing variables\n• Syntax errors", 
                      IBM_ORANGE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 5.3, 7, 2.2, 1.2, 
                      "Performance Issues\n\n• Timeout errors\n• Rate limiting\n• Network latency\n• Connection failures", 
                      IBM_PURPLE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 7.6, 7, 1.9, 1.2, 
                      "Resource Conflicts\n\n• State drift\n• Quota limits\n• Dependencies\n• Naming conflicts", 
                      IBM_CYAN, IBM_WHITE, 9)
    
    # Diagnostic tools
    create_rounded_box(ax, 0.5, 5.5, 3, 1.2, 
                      "Diagnostic Tools & Commands\n\nterraform providers • terraform version\nTF_LOG=DEBUG • ibmcloud target\nProvider validation scripts", 
                      IBM_BLUE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 3.8, 5.5, 3, 1.2, 
                      "Monitoring & Logging\n\nActivity Tracker • Provider logs\nPerformance metrics • Error tracking\nCustom headers • Trace analysis", 
                      IBM_GREEN, IBM_WHITE, 9)
    
    create_rounded_box(ax, 7.1, 5.5, 2.4, 1.2, 
                      "Automated Testing\n\nProvider validation\nConnectivity tests\nPermission checks\nHealth monitoring", 
                      IBM_DARK_BLUE, IBM_WHITE, 9)
    
    # Resolution strategies
    create_rounded_box(ax, 0.5, 3.8, 4.5, 1.5, 
                      "Resolution Strategies\n\nCredential verification • Permission updates • Configuration fixes\nPerformance tuning • Network optimization • Error handling", 
                      IBM_LIGHT_BLUE, IBM_WHITE, 9)
    
    create_rounded_box(ax, 5.2, 3.8, 4.3, 1.5, 
                      "Prevention Measures\n\nRegular validation • Automated testing • Monitoring alerts\nDocumentation • Training • Best practices", 
                      IBM_LIGHT_GRAY, IBM_GRAY, 9)
    
    # Escalation procedures
    create_rounded_box(ax, 1, 2, 8, 1.5, 
                      "Escalation & Support Procedures\n\nInternal documentation • Community forums • IBM Support tickets\nProvider issue tracking • Version rollback • Emergency procedures", 
                      IBM_ORANGE, IBM_WHITE, 10)
    
    # Recovery procedures
    create_rounded_box(ax, 2.5, 0.3, 5, 1.5, 
                      "Recovery & Continuity\n\nBackup configurations • Rollback procedures\nDisaster recovery • Alternative providers", 
                      IBM_GREEN, IBM_WHITE, 10)
    
    plt.tight_layout()
    plt.savefig('generated_diagrams/provider_troubleshooting.png', dpi=300, bbox_inches='tight')
    plt.close()

def main():
    """Generate all diagrams for provider configuration and authentication."""
    # Create output directory if it doesn't exist
    os.makedirs('generated_diagrams', exist_ok=True)
    
    print("Generating Provider Configuration and Authentication diagrams...")
    
    # Generate all diagrams
    diagram_1_provider_architecture()
    print("✅ Generated: provider_architecture.png")
    
    diagram_2_ibm_provider_config()
    print("✅ Generated: ibm_provider_config.png")
    
    diagram_3_authentication_security()
    print("✅ Generated: authentication_security.png")
    
    diagram_4_multi_provider_setup()
    print("✅ Generated: multi_provider_setup.png")
    
    diagram_5_provider_troubleshooting()
    print("✅ Generated: provider_troubleshooting.png")
    
    print("\n🎉 All diagrams generated successfully!")
    print("📁 Output directory: generated_diagrams/")
    print("📊 Resolution: 300 DPI for professional quality")
    print("🎨 Style: IBM Cloud branding with provider-focused design")

if __name__ == "__main__":
    main()
