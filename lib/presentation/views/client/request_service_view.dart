import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:preciso/domain/entities/service_entity.dart';
import 'package:preciso/presentation/viewmodels/service_viewmodel.dart';

class RequestServiceView extends StatefulWidget {
  const RequestServiceView({super.key});

  @override
  RequestServiceViewState createState() => RequestServiceViewState();
}

class RequestServiceViewState extends State<RequestServiceView> {
  final _formKey = GlobalKey<FormState>();
  String _selectedService = 'Eletricista';
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  final List<String> _services = [
    'Eletricista',
    'Encanador',
    'Pedreiro',
    'Pintor',
    'Marceneiro',
    'Técnico de Ar Condicionado',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serviceViewModel = Provider.of<ServiceViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar Serviço'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (serviceViewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    serviceViewModel.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              DropdownButtonFormField(
                value: _selectedService,
                items: _services.map((service) {
                  return DropdownMenuItem(
                    value: service,
                    child: Text(service),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedService = value.toString();
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Tipo de Serviço',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descreva o problema',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, descreva o serviço necessário';
                  }
                  return null;
                },
                onChanged: (_) => serviceViewModel.resetError(),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Endereço',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe o endereço';
                  }
                  return null;
                },
                onChanged: (_) => serviceViewModel.resetError(),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: serviceViewModel.isLoading
                    ? null
                    : () => _submitRequest(serviceViewModel),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: serviceViewModel.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Solicitar Profissional'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitRequest(ServiceViewModel serviceViewModel) async {
    if (_formKey.currentState!.validate()) {
      final request = ServiceEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        clientId: '',
        professionalId: '',
        serviceType: _selectedService,
        description: _descriptionController.text,
        address: _addressController.text,
        requestDate: DateTime.now(),
        status: 'pending',
      );

      await serviceViewModel.createServiceRequestWithCallback(
        request,
        onSuccess: () {
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Solicitação enviada com sucesso!')),
            );
          }
        },
        onError: (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro: $error')),
            );
          }
        },
      );
    }
  }

  // Future<void> _submitRequest(ServiceViewModel serviceViewModel) async {
  //   if (_formKey.currentState!.validate()) {
  //     final request = ServiceEntity(
  //       id: DateTime.now().millisecondsSinceEpoch.toString(),
  //       clientId: '',
  //       professionalId: '',
  //       serviceType: _selectedService,
  //       description: _descriptionController.text,
  //       address: _addressController.text,
  //       requestDate: DateTime.now(),
  //       status: 'pending',
  //     );

  //     try {
  //       await serviceViewModel.createServiceRequest(request);
  //       if (mounted) {
  //         Navigator.pop(context);
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Solicitação enviada com sucesso!')),
  //         );
  //       }
  //     } catch (e) {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Erro: ${e.toString()}')),
  //         );
  //       }
  //     }
  //   }
  // }
}