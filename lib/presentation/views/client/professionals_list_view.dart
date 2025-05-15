import 'package:flutter/material.dart';
import 'package:preciso/presentation/views/client/request_service_view.dart';
import 'package:provider/provider.dart';
import 'package:preciso/presentation/viewmodels/professional_viewmodel.dart';
import 'package:preciso/presentation/widgets/professional_card.dart';
import 'package:preciso/core/models/user_model.dart';

class ProfessionalsListView extends StatefulWidget {
  final String serviceType;

  const ProfessionalsListView({super.key, required this.serviceType});

  @override
  State<ProfessionalsListView> createState() => _ProfessionalsListViewState();
}

class _ProfessionalsListViewState extends State<ProfessionalsListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ProfessionalViewModel>(
        context,
        listen: false,
      );
      viewModel.loadProfessionals(widget.serviceType);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.serviceType}s Disponíveis'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ProfessionalViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(child: Text(viewModel.errorMessage!));
          }

          if (viewModel.professionals.isEmpty) {
            return const Center(child: Text('Nenhum profissional disponível'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: viewModel.professionals.length,
            itemBuilder: (context, index) {
              final professional = viewModel.professionals[index];
              return ProfessionalCard(
                professional: professional,
                onRequest: () => _showRequestDialog(context, professional),
              );
            },
          );
        },
      ),
    );
  }

  void _showRequestDialog(BuildContext context, UserModel professional) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Solicitar ${professional.profession}'),
            content: const Text(
              'Deseja solicitar os serviços deste profissional?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // _createServiceRequest(context, professional);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RequestServiceView(),
                    ),
                  );
                },
                child: const Text('Confirmar'),
              ),
            ],
          ),
    );
  }

  void _createServiceRequest(BuildContext context, UserModel professional) {
    final viewModel = Provider.of<ProfessionalViewModel>(
      context,
      listen: false,
    );
    viewModel.createRequest(
      professionalId: professional.uid,
      serviceType: widget.serviceType,
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitação enviada com sucesso!')),
        );
      },
      onError: (message) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $message')));
      },
    );
  }
}
