import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Dialog para exibir Termos de Uso e Política de Privacidade
class TermsAndPrivacyDialog extends StatefulWidget {
  final String initialDocument; // 'terms' ou 'privacy'

  const TermsAndPrivacyDialog({
    super.key,
    this.initialDocument = 'terms',
  });

  @override
  State<TermsAndPrivacyDialog> createState() => _TermsAndPrivacyDialogState();
}

class _TermsAndPrivacyDialogState extends State<TermsAndPrivacyDialog> {
  String _currentDocument = 'terms'; // 'terms' ou 'privacy'
  String _currentLanguage = 'pt'; // 'pt', 'en', 'es'

  @override
  void initState() {
    super.initState();
    _currentDocument = widget.initialDocument;
  }

  String _getTitle() {
    if (_currentDocument == 'terms') {
      switch (_currentLanguage) {
        case 'en':
          return 'Terms of Use';
        case 'es':
          return 'Términos de Uso';
        default:
          return 'Termos de Uso';
      }
    } else {
      switch (_currentLanguage) {
        case 'en':
          return 'Privacy Policy';
        case 'es':
          return 'Política de Privacidad';
        default:
          return 'Política de Privacidade';
      }
    }
  }

  String _getContent() {
    if (_currentDocument == 'terms') {
      return _getTermsContent();
    } else {
      return _getPrivacyContent();
    }
  }

  String _getTermsContent() {
    switch (_currentLanguage) {
      case 'en':
        return _termsEnglish;
      case 'es':
        return _termsSpanish;
      default:
        return _termsPortuguese;
    }
  }

  String _getPrivacyContent() {
    switch (_currentLanguage) {
      case 'en':
        return _privacyEnglish;
      case 'es':
        return _privacySpanish;
      default:
        return _privacyPortuguese;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: isDark ? AppColors.slate900 : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.slate700 : AppColors.slate200,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getTitle(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.slate50 : AppColors.slate900,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: isDark ? AppColors.slate400 : AppColors.slate600,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Language Selector
                  Row(
                    children: [
                      Icon(
                        Icons.language,
                        size: 20,
                        color: isDark ? AppColors.slate400 : AppColors.slate600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getLanguageLabel(),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.slate400 : AppColors.slate600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.slate800 : AppColors.slate100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? AppColors.slate700 : AppColors.slate300,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _currentLanguage,
                              isExpanded: true,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: isDark ? AppColors.slate400 : AppColors.slate600,
                              ),
                              dropdownColor: isDark ? AppColors.slate800 : Colors.white,
                              style: TextStyle(
                                color: isDark ? AppColors.slate50 : AppColors.slate900,
                                fontSize: 14,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'pt',
                                  child: Row(
                                    children: [
                                      Text('🇧🇷'),
                                      SizedBox(width: 8),
                                      Text('Português'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'en',
                                  child: Row(
                                    children: [
                                      Text('🇺🇸'),
                                      SizedBox(width: 8),
                                      Text('English'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'es',
                                  child: Row(
                                    children: [
                                      Text('🇪🇸'),
                                      SizedBox(width: 8),
                                      Text('Español'),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _currentLanguage = value);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Document Selector
                  Row(
                    children: [
                      Expanded(
                        child: _DocumentTab(
                          label: 'Termos de Uso',
                          isActive: _currentDocument == 'terms',
                          onTap: () => setState(() => _currentDocument = 'terms'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DocumentTab(
                          label: 'Política',
                          isActive: _currentDocument == 'privacy',
                          onTap: () => setState(() => _currentDocument = 'privacy'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Text(
                  _getContent(),
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: isDark ? AppColors.slate300 : AppColors.slate700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageLabel() {
    switch (_currentLanguage) {
      case 'en':
        return 'Language:';
      case 'es':
        return 'Idioma:';
      default:
        return 'Idioma:';
    }
  }
}

/// Tab para alternar entre documentos
class _DocumentTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DocumentTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.teal500
                : (isDark ? AppColors.slate800 : AppColors.slate100),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? Colors.white
                    : (isDark ? AppColors.slate400 : AppColors.slate600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============ TERMOS DE USO ============

const String _termsPortuguese = '''
TERMOS DE USO - POLYS

1. ACEITAÇÃO DOS TERMOS

Ao acessar e usar a plataforma POLYS, você concorda em cumprir e estar vinculado a estes Termos de Uso. Se você não concordar com qualquer parte destes termos, não deve usar nossa plataforma.

2. DESCRIÇÃO DO SERVIÇO

POLYS é uma plataforma comunitária que permite aos usuários:
- Criar e gerenciar projetos comunitários
- Participar de votações e decisões coletivas
- Realizar doações para projetos
- Comprar e vender produtos e serviços locais
- Interagir com outros membros da comunidade

3. CADASTRO E CONTA

3.1. Para usar a plataforma, você deve criar uma conta fornecendo informações precisas e atualizadas.

3.2. Você é responsável por manter a confidencialidade de suas credenciais de acesso.

3.3. Você concorda em notificar imediatamente a POLYS sobre qualquer uso não autorizado de sua conta.

4. USO DA PLATAFORMA

4.1. Você concorda em usar a plataforma apenas para fins legais e de acordo com estes termos.

4.2. Você não deve:
- Violar qualquer lei ou regulamento
- Infringir direitos de propriedade intelectual
- Enviar conteúdo ofensivo, difamatório ou ilegal
- Interferir no funcionamento da plataforma
- Tentar acessar áreas restritas do sistema

5. PROJETOS E DOAÇÕES

5.1. Projetos criados na plataforma são de responsabilidade de seus criadores.

5.2. Doações são processadas através de sistema de escrow e podem ser reembolsadas se a meta não for atingida.

5.3. A POLYS cobra uma comissão de 10% sobre doações bem-sucedidas.

6. PRODUTOS E SERVIÇOS

6.1. Usuários podem listar produtos e serviços na plataforma.

6.2. A POLYS não se responsabiliza por transações entre usuários.

6.3. Qualquer disputa deve ser resolvida diretamente entre as partes.

7. PROPRIEDADE INTELECTUAL

7.1. Todo o conteúdo da plataforma é propriedade da POLYS ou de seus licenciadores.

7.2. Você mantém os direitos sobre o conteúdo que você cria e publica.

8. LIMITAÇÃO DE RESPONSABILIDADE

8.1. A POLYS não garante que a plataforma estará sempre disponível ou livre de erros.

8.2. A POLYS não se responsabiliza por danos diretos, indiretos ou consequenciais decorrentes do uso da plataforma.

9. MODIFICAÇÕES DOS TERMOS

9.1. A POLYS reserva-se o direito de modificar estes termos a qualquer momento.

9.2. Alterações serão comunicadas aos usuários através da plataforma.

10. RESCISÃO

10.1. A POLYS pode suspender ou encerrar sua conta a qualquer momento por violação destes termos.

10.2. Você pode encerrar sua conta a qualquer momento através das configurações.

11. LEI APLICÁVEL

11.1. Estes termos são regidos pelas leis brasileiras.

11.2. Qualquer disputa será resolvida nos tribunais competentes do Brasil.

12. CONTATO

Para questões sobre estes termos, entre em contato através do suporte da plataforma.

Última atualização: Janeiro de 2025
''';

const String _termsEnglish = '''
TERMS OF USE - POLYS

1. ACCEPTANCE OF TERMS

By accessing and using the POLYS platform, you agree to comply with and be bound by these Terms of Use. If you do not agree with any part of these terms, you should not use our platform.

2. SERVICE DESCRIPTION

POLYS is a community platform that allows users to:
- Create and manage community projects
- Participate in votes and collective decisions
- Make donations to projects
- Buy and sell local products and services
- Interact with other community members

3. REGISTRATION AND ACCOUNT

3.1. To use the platform, you must create an account by providing accurate and up-to-date information.

3.2. You are responsible for maintaining the confidentiality of your access credentials.

3.3. You agree to immediately notify POLYS of any unauthorized use of your account.

4. PLATFORM USE

4.1. You agree to use the platform only for lawful purposes and in accordance with these terms.

4.2. You must not:
- Violate any law or regulation
- Infringe intellectual property rights
- Send offensive, defamatory, or illegal content
- Interfere with platform operation
- Attempt to access restricted areas of the system

5. PROJECTS AND DONATIONS

5.1. Projects created on the platform are the responsibility of their creators.

5.2. Donations are processed through an escrow system and may be refunded if the goal is not reached.

5.3. POLYS charges a 10% commission on successful donations.

6. PRODUCTS AND SERVICES

6.1. Users may list products and services on the platform.

6.2. POLYS is not responsible for transactions between users.

6.3. Any dispute must be resolved directly between the parties.

7. INTELLECTUAL PROPERTY

7.1. All platform content is the property of POLYS or its licensors.

7.2. You retain rights to content you create and publish.

8. LIMITATION OF LIABILITY

8.1. POLYS does not guarantee that the platform will always be available or error-free.

8.2. POLYS is not liable for direct, indirect, or consequential damages arising from platform use.

9. TERM MODIFICATIONS

9.1. POLYS reserves the right to modify these terms at any time.

9.2. Changes will be communicated to users through the platform.

10. TERMINATION

10.1. POLYS may suspend or terminate your account at any time for violation of these terms.

10.2. You may terminate your account at any time through settings.

11. APPLICABLE LAW

11.1. These terms are governed by Brazilian laws.

11.2. Any dispute will be resolved in competent courts of Brazil.

12. CONTACT

For questions about these terms, contact us through the platform support.

Last updated: January 2025
''';

const String _termsSpanish = '''
TÉRMINOS DE USO - POLYS

1. ACEPTACIÓN DE LOS TÉRMINOS

Al acceder y usar la plataforma POLYS, usted acepta cumplir y estar sujeto a estos Términos de Uso. Si no está de acuerdo con alguna parte de estos términos, no debe usar nuestra plataforma.

2. DESCRIPCIÓN DEL SERVICIO

POLYS es una plataforma comunitaria que permite a los usuarios:
- Crear y gestionar proyectos comunitarios
- Participar en votaciones y decisiones colectivas
- Realizar donaciones a proyectos
- Comprar y vender productos y servicios locales
- Interactuar con otros miembros de la comunidad

3. REGISTRO Y CUENTA

3.1. Para usar la plataforma, debe crear una cuenta proporcionando información precisa y actualizada.

3.2. Usted es responsable de mantener la confidencialidad de sus credenciales de acceso.

3.3. Usted acepta notificar inmediatamente a POLYS sobre cualquier uso no autorizado de su cuenta.

4. USO DE LA PLATAFORMA

4.1. Usted acepta usar la plataforma solo para fines legales y de acuerdo con estos términos.

4.2. No debe:
- Violar cualquier ley o regulación
- Infringir derechos de propiedad intelectual
- Enviar contenido ofensivo, difamatorio o ilegal
- Interferir con el funcionamiento de la plataforma
- Intentar acceder a áreas restringidas del sistema

5. PROYECTOS Y DONACIONES

5.1. Los proyectos creados en la plataforma son responsabilidad de sus creadores.

5.2. Las donaciones se procesan a través de un sistema de depósito en garantía y pueden ser reembolsadas si no se alcanza la meta.

5.3. POLYS cobra una comisión del 10% sobre donaciones exitosas.

6. PRODUCTOS Y SERVICIOS

6.1. Los usuarios pueden listar productos y servicios en la plataforma.

6.2. POLYS no se responsabiliza por transacciones entre usuarios.

6.3. Cualquier disputa debe resolverse directamente entre las partes.

7. PROPIEDAD INTELECTUAL

7.1. Todo el contenido de la plataforma es propiedad de POLYS o sus licenciantes.

7.2. Usted conserva los derechos sobre el contenido que crea y publica.

8. LIMITACIÓN DE RESPONSABILIDAD

8.1. POLYS no garantiza que la plataforma estará siempre disponible o libre de errores.

8.2. POLYS no se responsabiliza por daños directos, indirectos o consecuentes derivados del uso de la plataforma.

9. MODIFICACIONES DE LOS TÉRMINOS

9.1. POLYS se reserva el derecho de modificar estos términos en cualquier momento.

9.2. Los cambios serán comunicados a los usuarios a través de la plataforma.

10. TERMINACIÓN

10.1. POLYS puede suspender o terminar su cuenta en cualquier momento por violación de estos términos.

10.2. Puede terminar su cuenta en cualquier momento a través de la configuración.

11. LEY APLICABLE

11.1. Estos términos se rigen por las leyes brasileñas.

11.2. Cualquier disputa se resolverá en los tribunales competentes de Brasil.

12. CONTACTO

Para preguntas sobre estos términos, contáctenos a través del soporte de la plataforma.

Última actualización: Enero de 2025
''';

// ============ POLÍTICA DE PRIVACIDADE ============

const String _privacyPortuguese = '''
POLÍTICA DE PRIVACIDADE - POLYS

1. INTRODUÇÃO

Esta Política de Privacidade descreve como a POLYS coleta, usa e protege suas informações pessoais quando você usa nossa plataforma.

2. INFORMAÇÕES COLETADAS

2.1. Informações que você nos fornece:
- Nome completo
- Endereço de e-mail
- Telefone
- Endereço residencial
- Informações de pagamento
- Conteúdo que você publica na plataforma

2.2. Informações coletadas automaticamente:
- Dados de localização
- Informações do dispositivo
- Logs de acesso
- Cookies e tecnologias similares

3. COMO USAMOS SUAS INFORMAÇÕES

3.1. Utilizamos suas informações para:
- Fornecer e melhorar nossos serviços
- Processar transações e pagamentos
- Comunicar-nos com você
- Personalizar sua experiência
- Detectar e prevenir fraudes
- Cumprir obrigações legais

4. COMPARTILHAMENTO DE INFORMAÇÕES

4.1. Não vendemos suas informações pessoais.

4.2. Podemos compartilhar informações com:
- Prestadores de serviços (processamento de pagamentos)
- Autoridades legais quando exigido por lei
- Outros usuários (apenas informações públicas do perfil)

5. SEGURANÇA

5.1. Implementamos medidas de segurança técnicas e organizacionais para proteger suas informações.

5.2. Usamos criptografia para proteger dados sensíveis.

5.3. No entanto, nenhum método de transmissão pela internet é 100% seguro.

6. SEUS DIREITOS

6.1. Você tem o direito de:
- Acessar suas informações pessoais
- Corrigir informações incorretas
- Solicitar exclusão de dados
- Opor-se ao processamento
- Portabilidade de dados

6.2. Para exercer seus direitos, entre em contato através do suporte.

7. COOKIES

7.1. Usamos cookies para melhorar sua experiência na plataforma.

7.2. Você pode gerenciar preferências de cookies nas configurações do navegador.

8. RETENÇÃO DE DADOS

8.1. Mantemos suas informações enquanto sua conta estiver ativa ou conforme necessário para fornecer serviços.

8.2. Podemos reter informações por períodos mais longos quando exigido por lei.

9. MENORES DE IDADE

9.1. Nossa plataforma não é destinada a menores de 18 anos.

9.2. Não coletamos intencionalmente informações de menores.

10. ALTERAÇÕES NESTA POLÍTICA

10.1. Podemos atualizar esta política periodicamente.

10.2. Notificaremos sobre alterações significativas através da plataforma.

11. LEI GERAL DE PROTEÇÃO DE DADOS (LGPD)

11.1. Esta política está em conformidade com a LGPD brasileira.

11.2. Você tem todos os direitos garantidos pela legislação de proteção de dados.

12. CONTATO

Para questões sobre privacidade, entre em contato através do suporte da plataforma.

Última atualização: Janeiro de 2025
''';

const String _privacyEnglish = '''
PRIVACY POLICY - POLYS

1. INTRODUCTION

This Privacy Policy describes how POLYS collects, uses, and protects your personal information when you use our platform.

2. INFORMATION COLLECTED

2.1. Information you provide to us:
- Full name
- Email address
- Phone number
- Residential address
- Payment information
- Content you publish on the platform

2.2. Automatically collected information:
- Location data
- Device information
- Access logs
- Cookies and similar technologies

3. HOW WE USE YOUR INFORMATION

3.1. We use your information to:
- Provide and improve our services
- Process transactions and payments
- Communicate with you
- Personalize your experience
- Detect and prevent fraud
- Comply with legal obligations

4. INFORMATION SHARING

4.1. We do not sell your personal information.

4.2. We may share information with:
- Service providers (payment processing)
- Legal authorities when required by law
- Other users (only public profile information)

5. SECURITY

5.1. We implement technical and organizational security measures to protect your information.

5.2. We use encryption to protect sensitive data.

5.3. However, no method of internet transmission is 100% secure.

6. YOUR RIGHTS

6.1. You have the right to:
- Access your personal information
- Correct incorrect information
- Request data deletion
- Object to processing
- Data portability

6.2. To exercise your rights, contact us through support.

7. COOKIES

7.1. We use cookies to improve your experience on the platform.

7.2. You can manage cookie preferences in browser settings.

8. DATA RETENTION

8.1. We keep your information while your account is active or as needed to provide services.

8.2. We may retain information for longer periods when required by law.

9. MINORS

9.1. Our platform is not intended for users under 18 years of age.

9.2. We do not knowingly collect information from minors.

10. CHANGES TO THIS POLICY

10.1. We may update this policy periodically.

10.2. We will notify you of significant changes through the platform.

11. GENERAL DATA PROTECTION LAW (LGPD)

11.1. This policy complies with Brazilian LGPD.

11.2. You have all rights guaranteed by data protection legislation.

12. CONTACT

For privacy questions, contact us through platform support.

Last updated: January 2025
''';

const String _privacySpanish = '''
POLÍTICA DE PRIVACIDAD - POLYS

1. INTRODUCCIÓN

Esta Política de Privacidad describe cómo POLYS recopila, usa y protege su información personal cuando usa nuestra plataforma.

2. INFORMACIÓN RECOPILADA

2.1. Información que nos proporciona:
- Nombre completo
- Dirección de correo electrónico
- Número de teléfono
- Dirección residencial
- Información de pago
- Contenido que publica en la plataforma

2.2. Información recopilada automáticamente:
- Datos de ubicación
- Información del dispositivo
- Registros de acceso
- Cookies y tecnologías similares

3. CÓMO USAMOS SU INFORMACIÓN

3.1. Utilizamos su información para:
- Proporcionar y mejorar nuestros servicios
- Procesar transacciones y pagos
- Comunicarnos con usted
- Personalizar su experiencia
- Detectar y prevenir fraudes
- Cumplir con obligaciones legales

4. COMPARTIR INFORMACIÓN

4.1. No vendemos su información personal.

4.2. Podemos compartir información con:
- Proveedores de servicios (procesamiento de pagamentos)
- Autoridades legales cuando lo exija la ley
- Otros usuarios (solo información pública del perfil)

5. SEGURIDAD

5.1. Implementamos medidas de seguridad técnicas y organizativas para proteger su información.

5.2. Usamos encriptación para proteger datos sensibles.

5.3. Sin embargo, ningún método de transmisión por internet es 100% seguro.

6. SUS DERECHOS

6.1. Tiene derecho a:
- Acceder a su información personal
- Corregir información incorrecta
- Solicitar eliminación de datos
- Oponerse al procesamiento
- Portabilidad de datos

6.2. Para ejercer sus derechos, contáctenos a través del soporte.

7. COOKIES

7.1. Usamos cookies para mejorar su experiencia en la plataforma.

7.2. Puede gestionar las preferencias de cookies en la configuración del navegador.

8. RETENCIÓN DE DATOS

8.1. Mantenemos su información mientras su cuenta esté activa o según sea necesario para proporcionar servicios.

8.2. Podemos retener información por períodos más largos cuando lo exija la ley.

9. MENORES DE EDAD

9.1. Nuestra plataforma no está destinada a usuarios menores de 18 años.

9.2. No recopilamos intencionalmente información de menores.

10. CAMBIOS A ESTA POLÍTICA

10.1. Podemos actualizar esta política periódicamente.

10.2. Le notificaremos sobre cambios significativos a través de la plataforma.

11. LEY GENERAL DE PROTECCIÓN DE DATOS (LGPD)

11.1. Esta política cumple con la LGPD brasileña.

11.2. Tiene todos los derechos garantizados por la legislación de protección de datos.

12. CONTACTO

Para preguntas sobre privacidad, contáctenos a través del soporte de la plataforma.

Última actualización: Enero de 2025
''';

