#!/usr/bin/env python3
"""
IBM Cloud Terraform Training - Topic 7.1: Managing Secrets and Credentials
Diagram as Code (DaC) Implementation

This script generates 5 professional security diagrams for secrets management:
1. Enterprise Security Architecture Overview
2. Secrets Lifecycle Management Workflow  
3. Compliance Framework Implementation Matrix
4. Threat Model and Security Mitigation Strategies
5. Enterprise Governance and Monitoring Dashboard

Author: IBM Cloud Terraform Training Team
Version: 1.0.0
Date: 2024-09-15
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, ConnectionPatch, Circle
import numpy as np
import seaborn as sns
from datetime import datetime
import os

# Set IBM Cloud brand colors and styling
IBM_COLORS = {
    'primary_blue': '#0f62fe',
    'secondary_blue': '#4589ff', 
    'dark_blue': '#002d9c',
    'light_blue': '#a6c8ff',
    'success_green': '#24a148',
    'warning_yellow': '#f1c21b',
    'error_red': '#da1e28',
    'neutral_gray': '#525252',
    'light_gray': '#f4f4f4',
    'white': '#ffffff'
}

# Configure matplotlib for high-quality output
plt.rcParams.update({
    'figure.dpi': 300,
    'savefig.dpi': 300,
    'font.family': 'IBM Plex Sans',
    'font.size': 10,
    'axes.titlesize': 14,
    'axes.labelsize': 12,
    'xtick.labelsize': 10,
    'ytick.labelsize': 10,
    'legend.fontsize': 10,
    'figure.titlesize': 16
})

class SecurityDiagramGenerator:
    """Professional security diagram generator for IBM Cloud Terraform training."""
    
    def __init__(self, output_dir='diagrams'):
        """Initialize the diagram generator with output directory."""
        self.output_dir = output_dir
        self.ensure_output_directory()
        
    def ensure_output_directory(self):
        """Create output directory if it doesn't exist."""
        if not os.path.exists(self.output_dir):
            os.makedirs(self.output_dir)
    
    def create_enterprise_security_architecture(self):
        """
        Diagram 1: Enterprise Security Architecture Overview
        Shows comprehensive IBM Cloud security services integration with zero trust principles
        """
        fig, ax = plt.subplots(1, 1, figsize=(16, 12))
        ax.set_xlim(0, 10)
        ax.set_ylim(0, 10)
        ax.axis('off')
        
        # Title and subtitle
        fig.suptitle('Enterprise Security Architecture Overview', 
                    fontsize=20, fontweight='bold', color=IBM_COLORS['primary_blue'])
        ax.text(5, 9.5, 'IBM Cloud Security Services with Zero Trust Architecture',
                ha='center', va='center', fontsize=14, color=IBM_COLORS['neutral_gray'])
        
        # Zero Trust Perimeter
        zero_trust_box = FancyBboxPatch((0.5, 1), 9, 7.5, 
                                       boxstyle="round,pad=0.1",
                                       facecolor=IBM_COLORS['light_blue'],
                                       edgecolor=IBM_COLORS['primary_blue'],
                                       linewidth=3, alpha=0.3)
        ax.add_patch(zero_trust_box)
        ax.text(5, 8.7, 'Zero Trust Security Perimeter', ha='center', va='center',
                fontsize=12, fontweight='bold', color=IBM_COLORS['primary_blue'])
        
        # IBM Cloud Key Protect
        key_protect = FancyBboxPatch((1, 6.5), 2, 1.5,
                                    boxstyle="round,pad=0.05",
                                    facecolor=IBM_COLORS['primary_blue'],
                                    edgecolor=IBM_COLORS['dark_blue'],
                                    linewidth=2)
        ax.add_patch(key_protect)
        ax.text(2, 7.25, 'IBM Cloud\nKey Protect', ha='center', va='center',
                fontsize=10, fontweight='bold', color=IBM_COLORS['white'])
        ax.text(2, 6.8, 'FIPS 140-2 Level 3\nHSM Encryption', ha='center', va='center',
                fontsize=8, color=IBM_COLORS['white'])
        
        # IBM Cloud Secrets Manager
        secrets_manager = FancyBboxPatch((4, 6.5), 2, 1.5,
                                        boxstyle="round,pad=0.05",
                                        facecolor=IBM_COLORS['secondary_blue'],
                                        edgecolor=IBM_COLORS['primary_blue'],
                                        linewidth=2)
        ax.add_patch(secrets_manager)
        ax.text(5, 7.25, 'IBM Cloud\nSecrets Manager', ha='center', va='center',
                fontsize=10, fontweight='bold', color=IBM_COLORS['white'])
        ax.text(5, 6.8, 'Automated Rotation\nLifecycle Management', ha='center', va='center',
                fontsize=8, color=IBM_COLORS['white'])
        
        # IBM Cloud IAM
        iam_service = FancyBboxPatch((7, 6.5), 2, 1.5,
                                    boxstyle="round,pad=0.05",
                                    facecolor=IBM_COLORS['success_green'],
                                    edgecolor=IBM_COLORS['primary_blue'],
                                    linewidth=2)
        ax.add_patch(iam_service)
        ax.text(8, 7.25, 'IBM Cloud\nIAM', ha='center', va='center',
                fontsize=10, fontweight='bold', color=IBM_COLORS['white'])
        ax.text(8, 6.8, 'Zero Trust Access\nLeast Privilege', ha='center', va='center',
                fontsize=8, color=IBM_COLORS['white'])
        
        # Application Layer
        app_layer = FancyBboxPatch((1.5, 4.5), 7, 1.5,
                                  boxstyle="round,pad=0.05",
                                  facecolor=IBM_COLORS['light_gray'],
                                  edgecolor=IBM_COLORS['neutral_gray'],
                                  linewidth=2)
        ax.add_patch(app_layer)
        ax.text(5, 5.25, 'Application Workloads', ha='center', va='center',
                fontsize=12, fontweight='bold', color=IBM_COLORS['neutral_gray'])
        
        # Microservices
        for i, service in enumerate(['Web App', 'API Gateway', 'Database', 'Analytics']):
            service_box = FancyBboxPatch((2 + i*1.5, 4.7), 1.2, 0.6,
                                        boxstyle="round,pad=0.02",
                                        facecolor=IBM_COLORS['white'],
                                        edgecolor=IBM_COLORS['neutral_gray'],
                                        linewidth=1)
            ax.add_patch(service_box)
            ax.text(2.6 + i*1.5, 5, service, ha='center', va='center',
                    fontsize=8, color=IBM_COLORS['neutral_gray'])
        
        # Activity Tracker
        activity_tracker = FancyBboxPatch((1, 2.5), 3, 1.5,
                                         boxstyle="round,pad=0.05",
                                         facecolor=IBM_COLORS['warning_yellow'],
                                         edgecolor=IBM_COLORS['primary_blue'],
                                         linewidth=2)
        ax.add_patch(activity_tracker)
        ax.text(2.5, 3.25, 'IBM Cloud\nActivity Tracker', ha='center', va='center',
                fontsize=10, fontweight='bold', color=IBM_COLORS['neutral_gray'])
        ax.text(2.5, 2.8, 'Comprehensive Audit\nCompliance Monitoring', ha='center', va='center',
                fontsize=8, color=IBM_COLORS['neutral_gray'])
        
        # Security Monitoring
        monitoring = FancyBboxPatch((6, 2.5), 3, 1.5,
                                   boxstyle="round,pad=0.05",
                                   facecolor=IBM_COLORS['error_red'],
                                   edgecolor=IBM_COLORS['primary_blue'],
                                   linewidth=2)
        ax.add_patch(monitoring)
        ax.text(7.5, 3.25, 'Security Monitoring\n& Alerting', ha='center', va='center',
                fontsize=10, fontweight='bold', color=IBM_COLORS['white'])
        ax.text(7.5, 2.8, 'Real-time Threat Detection\nIncident Response', ha='center', va='center',
                fontsize=8, color=IBM_COLORS['white'])
        
        # Connection arrows
        connections = [
            ((2, 6.5), (2.5, 6)),    # Key Protect to Apps
            ((5, 6.5), (5, 6)),      # Secrets Manager to Apps
            ((8, 6.5), (7.5, 6)),    # IAM to Apps
            ((3.5, 4.5), (2.5, 4)),  # Apps to Activity Tracker
            ((6.5, 4.5), (7.5, 4))   # Apps to Monitoring
        ]
        
        for start, end in connections:
            arrow = ConnectionPatch(start, end, "data", "data",
                                  arrowstyle="->", shrinkA=5, shrinkB=5,
                                  mutation_scale=20, fc=IBM_COLORS['primary_blue'],
                                  ec=IBM_COLORS['primary_blue'], linewidth=2)
            ax.add_patch(arrow)
        
        # Compliance badges
        compliance_labels = ['SOC2', 'ISO27001', 'GDPR', 'HIPAA']
        for i, label in enumerate(compliance_labels):
            badge = Circle((1.5 + i*0.8, 1.5), 0.25, 
                          facecolor=IBM_COLORS['success_green'],
                          edgecolor=IBM_COLORS['white'], linewidth=2)
            ax.add_patch(badge)
            ax.text(1.5 + i*0.8, 1.5, label, ha='center', va='center',
                    fontsize=8, fontweight='bold', color=IBM_COLORS['white'])
        
        ax.text(3, 0.8, 'Compliance Frameworks', ha='center', va='center',
                fontsize=10, fontweight='bold', color=IBM_COLORS['neutral_gray'])
        
        # Business value metrics
        ax.text(7, 1.2, 'Business Value:', ha='left', va='center',
                fontsize=10, fontweight='bold', color=IBM_COLORS['primary_blue'])
        ax.text(7, 0.9, '• 800%+ ROI over 3 years', ha='left', va='center',
                fontsize=9, color=IBM_COLORS['neutral_gray'])
        ax.text(7, 0.6, '• 95% breach risk reduction', ha='left', va='center',
                fontsize=9, color=IBM_COLORS['neutral_gray'])
        ax.text(7, 0.3, '• 70% compliance cost savings', ha='left', va='center',
                fontsize=9, color=IBM_COLORS['neutral_gray'])
        
        plt.tight_layout()
        plt.savefig(f'{self.output_dir}/01_enterprise_security_architecture.png', 
                   dpi=300, bbox_inches='tight', facecolor='white')
        plt.close()
        
    def create_secrets_lifecycle_workflow(self):
        """
        Diagram 2: Secrets Lifecycle Management Workflow
        Shows end-to-end secrets management with automated rotation and governance
        """
        fig, ax = plt.subplots(1, 1, figsize=(14, 10))
        ax.set_xlim(0, 10)
        ax.set_ylim(0, 8)
        ax.axis('off')
        
        # Title
        fig.suptitle('Secrets Lifecycle Management Workflow', 
                    fontsize=20, fontweight='bold', color=IBM_COLORS['primary_blue'])
        ax.text(5, 7.5, 'Automated Secrets Management with IBM Cloud Secrets Manager',
                ha='center', va='center', fontsize=14, color=IBM_COLORS['neutral_gray'])
        
        # Workflow stages
        stages = [
            {'name': 'Secret\nCreation', 'pos': (1.5, 6), 'color': IBM_COLORS['primary_blue']},
            {'name': 'Secure\nStorage', 'pos': (3.5, 6), 'color': IBM_COLORS['secondary_blue']},
            {'name': 'Access\nControl', 'pos': (5.5, 6), 'color': IBM_COLORS['success_green']},
            {'name': 'Automated\nRotation', 'pos': (7.5, 6), 'color': IBM_COLORS['warning_yellow']},
            {'name': 'Audit &\nCompliance', 'pos': (9, 6), 'color': IBM_COLORS['error_red']}
        ]
        
        # Draw workflow stages
        for i, stage in enumerate(stages):
            # Stage circle
            circle = Circle(stage['pos'], 0.4, facecolor=stage['color'],
                           edgecolor=IBM_COLORS['white'], linewidth=3)
            ax.add_patch(circle)
            ax.text(stage['pos'][0], stage['pos'][1], stage['name'], 
                   ha='center', va='center', fontsize=9, fontweight='bold',
                   color=IBM_COLORS['white'])
            
            # Stage number
            number_circle = Circle((stage['pos'][0], stage['pos'][1] + 0.7), 0.15,
                                 facecolor=IBM_COLORS['neutral_gray'],
                                 edgecolor=IBM_COLORS['white'], linewidth=2)
            ax.add_patch(number_circle)
            ax.text(stage['pos'][0], stage['pos'][1] + 0.7, str(i+1),
                   ha='center', va='center', fontsize=8, fontweight='bold',
                   color=IBM_COLORS['white'])
            
            # Arrows between stages
            if i < len(stages) - 1:
                arrow = ConnectionPatch(
                    (stage['pos'][0] + 0.4, stage['pos'][1]),
                    (stages[i+1]['pos'][0] - 0.4, stages[i+1]['pos'][1]),
                    "data", "data", arrowstyle="->", shrinkA=5, shrinkB=5,
                    mutation_scale=20, fc=IBM_COLORS['primary_blue'],
                    ec=IBM_COLORS['primary_blue'], linewidth=2)
                ax.add_patch(arrow)
        
        # Detailed process descriptions
        descriptions = [
            {'pos': (1.5, 4.8), 'text': 'Dynamic Generation\nTemplate-based\nPolicy Enforcement'},
            {'pos': (3.5, 4.8), 'text': 'Encrypted at Rest\nKey Protect Integration\nVersion Management'},
            {'pos': (5.5, 4.8), 'text': 'IAM Integration\nLeast Privilege\nTime-based Access'},
            {'pos': (7.5, 4.8), 'text': 'Scheduled Rotation\nZero-downtime\nApplication Hooks'},
            {'pos': (9, 4.8), 'text': 'Activity Tracking\nCompliance Reports\nAudit Evidence'}
        ]
        
        for desc in descriptions:
            ax.text(desc['pos'][0], desc['pos'][1], desc['text'],
                   ha='center', va='center', fontsize=8,
                   color=IBM_COLORS['neutral_gray'])
        
        # Rotation cycle detail
        rotation_box = FancyBboxPatch((1, 2.5), 8, 1.5,
                                     boxstyle="round,pad=0.1",
                                     facecolor=IBM_COLORS['light_gray'],
                                     edgecolor=IBM_COLORS['primary_blue'],
                                     linewidth=2, alpha=0.8)
        ax.add_patch(rotation_box)
        
        ax.text(5, 3.7, 'Automated Rotation Cycle (30-day default)',
                ha='center', va='center', fontsize=12, fontweight='bold',
                color=IBM_COLORS['primary_blue'])
        
        # Rotation steps
        rotation_steps = [
            'Pre-rotation\nWebhook', 'Generate New\nCredentials', 'Update\nApplications',
            'Validate\nConnectivity', 'Retire Old\nCredentials', 'Post-rotation\nWebhook'
        ]
        
        for i, step in enumerate(rotation_steps):
            x_pos = 1.5 + i * 1.2
            step_box = FancyBboxPatch((x_pos - 0.4, 2.8), 0.8, 0.6,
                                     boxstyle="round,pad=0.02",
                                     facecolor=IBM_COLORS['white'],
                                     edgecolor=IBM_COLORS['secondary_blue'],
                                     linewidth=1)
            ax.add_patch(step_box)
            ax.text(x_pos, 3.1, step, ha='center', va='center',
                   fontsize=7, color=IBM_COLORS['neutral_gray'])
            
            if i < len(rotation_steps) - 1:
                arrow = ConnectionPatch((x_pos + 0.4, 3.1), (x_pos + 0.8, 3.1),
                                      "data", "data", arrowstyle="->",
                                      shrinkA=2, shrinkB=2, mutation_scale=15,
                                      fc=IBM_COLORS['secondary_blue'],
                                      ec=IBM_COLORS['secondary_blue'], linewidth=1.5)
                ax.add_patch(arrow)
        
        # Security metrics
        metrics_box = FancyBboxPatch((1, 0.5), 8, 1.5,
                                    boxstyle="round,pad=0.1",
                                    facecolor=IBM_COLORS['light_blue'],
                                    edgecolor=IBM_COLORS['primary_blue'],
                                    linewidth=2, alpha=0.3)
        ax.add_patch(metrics_box)
        
        ax.text(5, 1.7, 'Security & Business Metrics',
                ha='center', va='center', fontsize=12, fontweight='bold',
                color=IBM_COLORS['primary_blue'])
        
        metrics = [
            'MTTR: 15 min', 'Uptime: 99.99%', 'Compliance: 100%',
            'Cost Savings: 70%', 'Automation: 95%', 'ROI: 800%+'
        ]
        
        for i, metric in enumerate(metrics):
            x_pos = 1.5 + (i % 3) * 2.5
            y_pos = 1.3 if i < 3 else 0.9
            ax.text(x_pos, y_pos, metric, ha='center', va='center',
                   fontsize=9, fontweight='bold', color=IBM_COLORS['primary_blue'])
        
        plt.tight_layout()
        plt.savefig(f'{self.output_dir}/02_secrets_lifecycle_workflow.png',
                   dpi=300, bbox_inches='tight', facecolor='white')
        plt.close()
        
    def create_compliance_framework_matrix(self):
        """
        Diagram 3: Compliance Framework Implementation Matrix
        Shows SOC2, ISO27001, GDPR control mapping with IBM Cloud security services
        """
        fig, ax = plt.subplots(1, 1, figsize=(16, 12))
        ax.set_xlim(0, 12)
        ax.set_ylim(0, 10)
        ax.axis('off')
        
        # Title
        fig.suptitle('Compliance Framework Implementation Matrix', 
                    fontsize=20, fontweight='bold', color=IBM_COLORS['primary_blue'])
        ax.text(6, 9.5, 'SOC2, ISO27001, and GDPR Control Mapping with IBM Cloud Security Services',
                ha='center', va='center', fontsize=14, color=IBM_COLORS['neutral_gray'])
        
        # Framework headers
        frameworks = [
            {'name': 'SOC2 Type II', 'pos': (2, 8.5), 'color': IBM_COLORS['primary_blue']},
            {'name': 'ISO 27001', 'pos': (6, 8.5), 'color': IBM_COLORS['secondary_blue']},
            {'name': 'GDPR', 'pos': (10, 8.5), 'color': IBM_COLORS['success_green']}
        ]
        
        for framework in frameworks:
            header_box = FancyBboxPatch((framework['pos'][0] - 1.5, framework['pos'][1] - 0.3),
                                       3, 0.6, boxstyle="round,pad=0.05",
                                       facecolor=framework['color'],
                                       edgecolor=IBM_COLORS['white'], linewidth=2)
            ax.add_patch(header_box)
            ax.text(framework['pos'][0], framework['pos'][1], framework['name'],
                   ha='center', va='center', fontsize=12, fontweight='bold',
                   color=IBM_COLORS['white'])
        
        # Control categories and mappings
        controls = [
            {
                'category': 'Access Controls',
                'soc2': 'CC6.1 - Logical Access\nCC6.2 - Authentication\nCC6.3 - Authorization',
                'iso27001': 'A.9 - Access Control\nA.18 - Compliance\nA.12 - Operations',
                'gdpr': 'Art. 25 - Data Protection\nArt. 32 - Security\nArt. 30 - Records',
                'y_pos': 7.5
            },
            {
                'category': 'Encryption & Key Management',
                'soc2': 'CC6.1 - Data Protection\nCC6.7 - Transmission\nCC6.8 - Disposal',
                'iso27001': 'A.10 - Cryptography\nA.13 - Communications\nA.8 - Asset Mgmt',
                'gdpr': 'Art. 32 - Encryption\nArt. 25 - Privacy by Design\nArt. 5 - Principles',
                'y_pos': 6
            },
            {
                'category': 'Monitoring & Logging',
                'soc2': 'CC7.1 - Detection\nCC7.2 - Monitoring\nCC7.3 - Evaluation',
                'iso27001': 'A.12 - Operations\nA.16 - Incident Mgmt\nA.18 - Compliance',
                'gdpr': 'Art. 33 - Breach Notification\nArt. 30 - Processing Records\nArt. 35 - Impact Assessment',
                'y_pos': 4.5
            },
            {
                'category': 'Risk Management',
                'soc2': 'CC3.1 - Risk Assessment\nCC3.2 - Risk Mitigation\nCC3.3 - Risk Monitoring',
                'iso27001': 'A.6 - Risk Management\nA.14 - System Acquisition\nA.17 - Business Continuity',
                'gdpr': 'Art. 35 - DPIA\nArt. 25 - Data Protection\nArt. 24 - Responsibility',
                'y_pos': 3
            }
        ]
        
        for control in controls:
            # Category label
            category_box = FancyBboxPatch((0.2, control['y_pos'] - 0.4), 1.6, 0.8,
                                         boxstyle="round,pad=0.05",
                                         facecolor=IBM_COLORS['neutral_gray'],
                                         edgecolor=IBM_COLORS['white'], linewidth=2)
            ax.add_patch(category_box)
            ax.text(1, control['y_pos'], control['category'], ha='center', va='center',
                   fontsize=10, fontweight='bold', color=IBM_COLORS['white'])
            
            # Control mappings
            mappings = [
                {'text': control['soc2'], 'x_pos': 2, 'color': IBM_COLORS['primary_blue']},
                {'text': control['iso27001'], 'x_pos': 6, 'color': IBM_COLORS['secondary_blue']},
                {'text': control['gdpr'], 'x_pos': 10, 'color': IBM_COLORS['success_green']}
            ]
            
            for mapping in mappings:
                mapping_box = FancyBboxPatch((mapping['x_pos'] - 1.4, control['y_pos'] - 0.4),
                                           2.8, 0.8, boxstyle="round,pad=0.05",
                                           facecolor=IBM_COLORS['light_gray'],
                                           edgecolor=mapping['color'], linewidth=2)
                ax.add_patch(mapping_box)
                ax.text(mapping['x_pos'], control['y_pos'], mapping['text'],
                       ha='center', va='center', fontsize=8,
                       color=IBM_COLORS['neutral_gray'])
        
        # IBM Cloud services mapping
        services_box = FancyBboxPatch((0.5, 1), 11, 1.5,
                                     boxstyle="round,pad=0.1",
                                     facecolor=IBM_COLORS['light_blue'],
                                     edgecolor=IBM_COLORS['primary_blue'],
                                     linewidth=2, alpha=0.3)
        ax.add_patch(services_box)
        
        ax.text(6, 2.2, 'IBM Cloud Security Services Implementation',
                ha='center', va='center', fontsize=14, fontweight='bold',
                color=IBM_COLORS['primary_blue'])
        
        services = [
            {'name': 'Key Protect', 'desc': 'FIPS 140-2 Level 3\nEncryption & Key Mgmt'},
            {'name': 'Secrets Manager', 'desc': 'Automated Rotation\nLifecycle Management'},
            {'name': 'IAM', 'desc': 'Zero Trust Access\nLeast Privilege'},
            {'name': 'Activity Tracker', 'desc': 'Comprehensive Audit\nCompliance Monitoring'}
        ]
        
        for i, service in enumerate(services):
            x_pos = 1.5 + i * 2.5
            service_box = FancyBboxPatch((x_pos - 0.8, 1.2), 1.6, 0.8,
                                        boxstyle="round,pad=0.05",
                                        facecolor=IBM_COLORS['white'],
                                        edgecolor=IBM_COLORS['primary_blue'],
                                        linewidth=2)
            ax.add_patch(service_box)
            ax.text(x_pos, 1.7, service['name'], ha='center', va='center',
                   fontsize=10, fontweight='bold', color=IBM_COLORS['primary_blue'])
            ax.text(x_pos, 1.4, service['desc'], ha='center', va='center',
                   fontsize=8, color=IBM_COLORS['neutral_gray'])
        
        plt.tight_layout()
        plt.savefig(f'{self.output_dir}/03_compliance_framework_matrix.png',
                   dpi=300, bbox_inches='tight', facecolor='white')
        plt.close()

    def create_threat_model_security_mitigation(self):
        """
        Diagram 4: Threat Model and Security Mitigation Strategies
        Shows attack vectors, security controls, and incident response procedures
        """
        fig, ax = plt.subplots(1, 1, figsize=(16, 12))
        ax.set_xlim(0, 12)
        ax.set_ylim(0, 10)
        ax.axis('off')

        # Title
        fig.suptitle('Threat Model and Security Mitigation Strategies',
                    fontsize=20, fontweight='bold', color=IBM_COLORS['primary_blue'])
        ax.text(6, 9.5, 'Comprehensive Security Controls and Incident Response with IBM Cloud',
                ha='center', va='center', fontsize=14, color=IBM_COLORS['neutral_gray'])

        # Threat categories
        threats = [
            {'name': 'Credential\nTheft', 'pos': (2, 8), 'severity': 'high'},
            {'name': 'Insider\nThreats', 'pos': (4, 8), 'severity': 'medium'},
            {'name': 'API\nAttacks', 'pos': (6, 8), 'severity': 'high'},
            {'name': 'Data\nExfiltration', 'pos': (8, 8), 'severity': 'high'},
            {'name': 'Compliance\nViolations', 'pos': (10, 8), 'severity': 'medium'}
        ]

        severity_colors = {
            'high': IBM_COLORS['error_red'],
            'medium': IBM_COLORS['warning_yellow'],
            'low': IBM_COLORS['success_green']
        }

        # Draw threat vectors
        for threat in threats:
            color = severity_colors[threat['severity']]
            threat_box = FancyBboxPatch((threat['pos'][0] - 0.6, threat['pos'][1] - 0.4),
                                       1.2, 0.8, boxstyle="round,pad=0.05",
                                       facecolor=color, edgecolor=IBM_COLORS['white'],
                                       linewidth=2)
            ax.add_patch(threat_box)
            ax.text(threat['pos'][0], threat['pos'][1], threat['name'],
                   ha='center', va='center', fontsize=9, fontweight='bold',
                   color=IBM_COLORS['white'])

        # Security controls layer
        controls_box = FancyBboxPatch((1, 5.5), 10, 1.5,
                                     boxstyle="round,pad=0.1",
                                     facecolor=IBM_COLORS['light_blue'],
                                     edgecolor=IBM_COLORS['primary_blue'],
                                     linewidth=3, alpha=0.3)
        ax.add_patch(controls_box)

        ax.text(6, 6.7, 'Security Controls and Mitigation Strategies',
                ha='center', va='center', fontsize=14, fontweight='bold',
                color=IBM_COLORS['primary_blue'])

        # Individual security controls
        controls = [
            {'name': 'MFA &\nZero Trust', 'pos': (2, 6.2), 'effectiveness': '95%'},
            {'name': 'Automated\nRotation', 'pos': (4, 6.2), 'effectiveness': '90%'},
            {'name': 'API Rate\nLimiting', 'pos': (6, 6.2), 'effectiveness': '85%'},
            {'name': 'Encryption\n& DLP', 'pos': (8, 6.2), 'effectiveness': '98%'},
            {'name': 'Continuous\nMonitoring', 'pos': (10, 6.2), 'effectiveness': '92%'}
        ]

        for control in controls:
            control_box = FancyBboxPatch((control['pos'][0] - 0.5, control['pos'][1] - 0.3),
                                        1, 0.6, boxstyle="round,pad=0.02",
                                        facecolor=IBM_COLORS['success_green'],
                                        edgecolor=IBM_COLORS['white'], linewidth=2)
            ax.add_patch(control_box)
            ax.text(control['pos'][0], control['pos'][1], control['name'],
                   ha='center', va='center', fontsize=8, fontweight='bold',
                   color=IBM_COLORS['white'])

            # Effectiveness percentage
            ax.text(control['pos'][0], control['pos'][1] - 0.6, control['effectiveness'],
                   ha='center', va='center', fontsize=8, fontweight='bold',
                   color=IBM_COLORS['success_green'])

        # Incident response workflow
        response_box = FancyBboxPatch((1, 3), 10, 2,
                                     boxstyle="round,pad=0.1",
                                     facecolor=IBM_COLORS['light_gray'],
                                     edgecolor=IBM_COLORS['neutral_gray'],
                                     linewidth=2, alpha=0.8)
        ax.add_patch(response_box)

        ax.text(6, 4.7, 'Automated Incident Response Workflow',
                ha='center', va='center', fontsize=14, fontweight='bold',
                color=IBM_COLORS['primary_blue'])

        # Response steps
        response_steps = [
            {'name': 'Detection', 'time': '< 5 min', 'pos': (2, 4.2)},
            {'name': 'Analysis', 'time': '< 10 min', 'pos': (3.5, 4.2)},
            {'name': 'Containment', 'time': '< 15 min', 'pos': (5, 4.2)},
            {'name': 'Eradication', 'time': '< 30 min', 'pos': (6.5, 4.2)},
            {'name': 'Recovery', 'time': '< 60 min', 'pos': (8, 4.2)},
            {'name': 'Lessons', 'time': '< 24 hrs', 'pos': (9.5, 4.2)}
        ]

        for i, step in enumerate(response_steps):
            step_circle = Circle(step['pos'], 0.3, facecolor=IBM_COLORS['primary_blue'],
                               edgecolor=IBM_COLORS['white'], linewidth=2)
            ax.add_patch(step_circle)
            ax.text(step['pos'][0], step['pos'][1], str(i+1), ha='center', va='center',
                   fontsize=10, fontweight='bold', color=IBM_COLORS['white'])

            ax.text(step['pos'][0], step['pos'][1] - 0.6, step['name'],
                   ha='center', va='center', fontsize=8, fontweight='bold',
                   color=IBM_COLORS['neutral_gray'])
            ax.text(step['pos'][0], step['pos'][1] - 0.8, step['time'],
                   ha='center', va='center', fontsize=7,
                   color=IBM_COLORS['neutral_gray'])

            # Arrows between steps
            if i < len(response_steps) - 1:
                arrow = ConnectionPatch(
                    (step['pos'][0] + 0.3, step['pos'][1]),
                    (response_steps[i+1]['pos'][0] - 0.3, response_steps[i+1]['pos'][1]),
                    "data", "data", arrowstyle="->", shrinkA=5, shrinkB=5,
                    mutation_scale=15, fc=IBM_COLORS['primary_blue'],
                    ec=IBM_COLORS['primary_blue'], linewidth=2)
                ax.add_patch(arrow)

        # Risk metrics and KPIs
        metrics_box = FancyBboxPatch((1, 0.5), 10, 2,
                                    boxstyle="round,pad=0.1",
                                    facecolor=IBM_COLORS['light_blue'],
                                    edgecolor=IBM_COLORS['primary_blue'],
                                    linewidth=2, alpha=0.3)
        ax.add_patch(metrics_box)

        ax.text(6, 2.2, 'Security Metrics and Risk Reduction',
                ha='center', va='center', fontsize=14, fontweight='bold',
                color=IBM_COLORS['primary_blue'])

        # Security metrics
        metrics = [
            {'label': 'Breach Risk Reduction', 'value': '95%', 'pos': (2.5, 1.7)},
            {'label': 'Mean Time to Detection', 'value': '5 min', 'pos': (5, 1.7)},
            {'label': 'Mean Time to Response', 'value': '15 min', 'pos': (7.5, 1.7)},
            {'label': 'Compliance Score', 'value': '100%', 'pos': (10, 1.7)},
            {'label': 'Security ROI', 'value': '800%+', 'pos': (3.5, 1.2)},
            {'label': 'Incident Reduction', 'value': '90%', 'pos': (6, 1.2)},
            {'label': 'Automation Level', 'value': '95%', 'pos': (8.5, 1.2)}
        ]

        for metric in metrics:
            ax.text(metric['pos'][0], metric['pos'][1], metric['label'],
                   ha='center', va='center', fontsize=9, fontweight='bold',
                   color=IBM_COLORS['neutral_gray'])
            ax.text(metric['pos'][0], metric['pos'][1] - 0.2, metric['value'],
                   ha='center', va='center', fontsize=11, fontweight='bold',
                   color=IBM_COLORS['primary_blue'])

        plt.tight_layout()
        plt.savefig(f'{self.output_dir}/04_threat_model_security_mitigation.png',
                   dpi=300, bbox_inches='tight', facecolor='white')
        plt.close()

    def create_enterprise_governance_dashboard(self):
        """
        Diagram 5: Enterprise Governance and Monitoring Dashboard
        Shows policy enforcement, compliance monitoring, and business value metrics
        """
        fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(16, 12))
        fig.suptitle('Enterprise Governance and Monitoring Dashboard',
                    fontsize=20, fontweight='bold', color=IBM_COLORS['primary_blue'])

        # Dashboard 1: Security Posture Overview
        ax1.set_title('Security Posture Overview', fontsize=14, fontweight='bold',
                     color=IBM_COLORS['primary_blue'])

        # Security score gauge
        theta = np.linspace(0, np.pi, 100)
        r = 1
        x_gauge = r * np.cos(theta)
        y_gauge = r * np.sin(theta)

        ax1.plot(x_gauge, y_gauge, color=IBM_COLORS['neutral_gray'], linewidth=8)

        # Security score (95%)
        score_theta = np.linspace(0, 0.95 * np.pi, 50)
        x_score = r * np.cos(score_theta)
        y_score = r * np.sin(score_theta)
        ax1.plot(x_score, y_score, color=IBM_COLORS['success_green'], linewidth=8)

        ax1.text(0, -0.3, '95%', ha='center', va='center', fontsize=24,
                fontweight='bold', color=IBM_COLORS['success_green'])
        ax1.text(0, -0.5, 'Security Score', ha='center', va='center', fontsize=12,
                color=IBM_COLORS['neutral_gray'])

        ax1.set_xlim(-1.5, 1.5)
        ax1.set_ylim(-0.8, 1.2)
        ax1.axis('off')

        # Dashboard 2: Compliance Status
        ax2.set_title('Compliance Status', fontsize=14, fontweight='bold',
                     color=IBM_COLORS['primary_blue'])

        compliance_frameworks = ['SOC2', 'ISO27001', 'GDPR', 'HIPAA']
        compliance_scores = [100, 98, 100, 95]
        colors = [IBM_COLORS['success_green'] if score >= 95 else
                 IBM_COLORS['warning_yellow'] if score >= 85 else
                 IBM_COLORS['error_red'] for score in compliance_scores]

        bars = ax2.bar(compliance_frameworks, compliance_scores, color=colors, alpha=0.8)
        ax2.set_ylim(0, 100)
        ax2.set_ylabel('Compliance Score (%)', fontsize=10)

        # Add value labels on bars
        for bar, score in zip(bars, compliance_scores):
            height = bar.get_height()
            ax2.text(bar.get_x() + bar.get_width()/2., height + 1,
                    f'{score}%', ha='center', va='bottom', fontweight='bold')

        # Dashboard 3: Business Value Metrics
        ax3.set_title('Business Value Metrics', fontsize=14, fontweight='bold',
                     color=IBM_COLORS['primary_blue'])

        # ROI trend over time
        months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun']
        roi_values = [200, 350, 500, 650, 750, 800]

        ax3.plot(months, roi_values, marker='o', linewidth=3, markersize=8,
                color=IBM_COLORS['primary_blue'], markerfacecolor=IBM_COLORS['success_green'])
        ax3.fill_between(months, roi_values, alpha=0.3, color=IBM_COLORS['primary_blue'])
        ax3.set_ylabel('ROI (%)', fontsize=10)
        ax3.set_title('Security Investment ROI Trend', fontsize=12)
        ax3.grid(True, alpha=0.3)

        # Dashboard 4: Operational Metrics
        ax4.set_title('Operational Metrics', fontsize=14, fontweight='bold',
                     color=IBM_COLORS['primary_blue'])

        # Metrics pie chart
        metrics_labels = ['Automated', 'Manual', 'Hybrid']
        metrics_values = [85, 10, 5]
        metrics_colors = [IBM_COLORS['success_green'], IBM_COLORS['error_red'],
                         IBM_COLORS['warning_yellow']]

        wedges, texts, autotexts = ax4.pie(metrics_values, labels=metrics_labels,
                                          colors=metrics_colors, autopct='%1.1f%%',
                                          startangle=90)

        # Enhance text appearance
        for autotext in autotexts:
            autotext.set_color('white')
            autotext.set_fontweight('bold')

        ax4.set_title('Security Operations Automation', fontsize=12)

        plt.tight_layout()
        plt.savefig(f'{self.output_dir}/05_enterprise_governance_dashboard.png',
                   dpi=300, bbox_inches='tight', facecolor='white')
        plt.close()
        
    def generate_all_diagrams(self):
        """Generate all 5 professional security diagrams."""
        print("🎨 Generating IBM Cloud Security Management Diagrams...")
        print(f"📁 Output directory: {self.output_dir}")
        
        try:
            print("📊 Creating Diagram 1: Enterprise Security Architecture Overview...")
            self.create_enterprise_security_architecture()
            
            print("🔄 Creating Diagram 2: Secrets Lifecycle Management Workflow...")
            self.create_secrets_lifecycle_workflow()
            
            print("📋 Creating Diagram 3: Compliance Framework Implementation Matrix...")
            self.create_compliance_framework_matrix()
            
            print("🛡️ Creating Diagram 4: Threat Model and Security Mitigation...")
            self.create_threat_model_security_mitigation()
            
            print("📈 Creating Diagram 5: Enterprise Governance Dashboard...")
            self.create_enterprise_governance_dashboard()
            
            print("✅ All diagrams generated successfully!")
            print(f"📂 Diagrams saved to: {os.path.abspath(self.output_dir)}")
            
        except Exception as e:
            print(f"❌ Error generating diagrams: {str(e)}")
            raise

if __name__ == "__main__":
    # Create diagram generator and generate all diagrams
    generator = SecurityDiagramGenerator()
    generator.generate_all_diagrams()
