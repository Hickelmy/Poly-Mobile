import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../providers/projects_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

/// Tela de criação de projeto
class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _shortDescController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _minVotesController = TextEditingController(text: '10');
  
  String? _selectedCategory;
  final List<String> _categories = [
    'seguranca',
    'infraestrutura',
    'cultura',
    'saude',
    'educacao',
    'lazer',
    'outro',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _shortDescController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _minVotesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProjectsProvider>();
    
    final project = await provider.createProject(
      title: _titleController.text,
      shortDescription: _shortDescController.text,
      description: _descriptionController.text,
      category: _selectedCategory,
      targetAmount: double.tryParse(_targetAmountController.text),
      minVotes: int.tryParse(_minVotesController.text),
    );

    if (!mounted) return;

    if (project != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Projeto criado com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Erro ao criar projeto'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Projeto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CustomTextField(
              controller: _titleController,
              label: 'Título do Projeto',
              hint: 'Ex: Reforma da praça central',
              validator: (v) => Validators.required(v, fieldName: 'Título'),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _shortDescController,
              label: 'Descrição Curta',
              hint: 'Resumo do projeto em uma frase',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descriptionController,
              label: 'Descrição Completa',
              hint: 'Descreva o projeto em detalhes...',
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categoria',
              ),
              items: _categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(_getCategoryName(cat)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value);
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _targetAmountController,
              label: 'Meta de Arrecadação (R\$)',
              hint: '10000',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _minVotesController,
              label: 'Mínimo de Votos para Aprovar',
              hint: '10',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            Consumer<ProjectsProvider>(
              builder: (context, provider, _) {
                return CustomButton(
                  text: 'Criar Projeto',
                  onPressed: _handleSubmit,
                  isLoading: provider.isLoading,
                  isFullWidth: true,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'seguranca': return 'Segurança';
      case 'infraestrutura': return 'Infraestrutura';
      case 'cultura': return 'Cultura';
      case 'saude': return 'Saúde';
      case 'educacao': return 'Educação';
      case 'lazer': return 'Lazer';
      default: return 'Outro';
    }
  }
}

