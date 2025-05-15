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




// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:preciso/domain/entities/service_entity.dart';
// import 'package:preciso/presentation/viewmodels/service_viewmodel.dart';
// //import 'package:url_launcher/url_launcher.dart'; // Import para funcionalidades de ligação e WhatsApp

// class RequestServiceView extends StatefulWidget {
//   //final String professionalName;
//   final String mainService;
//   final double rating;
//   final String? photoUrl; // Opcional
//   final String? phoneNumber; // Opcional
//   final String? whatsappNumber; // Opcional

//   const RequestServiceView({
//     super.key,
//     required this.professionalName,
//     required this.mainService,
//     required this.rating,
//     this.photoUrl,
//     this.phoneNumber,
//     this.whatsappNumber,
//   });

//   @override
//   RequestServiceViewState createState() => RequestServiceViewState();
// }

// class RequestServiceViewState extends State<RequestServiceView> {
//   final _formKey = GlobalKey<FormState>();
//   String _selectedService = ''; // Inicialize com um valor vazio ou o serviço do profissional
//   final _descriptionController = TextEditingController();
//   final _addressController = TextEditingController();

//   // A lista de serviços agora pode não ser necessária, pois já temos o mainService do profissional
//   // final List<String> _services = [
//   //   'Eletricista',
//   //   'Encanador',
//   //   'Pedreiro',
//   //   'Pintor',
//   //   'Marceneiro',
//   //   'Técnico de Ar Condicionado',
//   // ];

//   @override
//   void initState() {
//     super.initState();
//     _selectedService = widget.mainService; // Define o serviço do profissional ao iniciar
//   }

//   @override
//   void dispose() {
//     _descriptionController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }

//   // Future<void> _launchUrl(String url) async {
//   //   final Uri uri = Uri.parse(url);
//   //   if (!await launchUrl(uri)) {
//   //     if (mounted) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(content: Text('Não foi possível abrir o link.')),
//   //       );
//   //     }
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     final serviceViewModel = Provider.of<ServiceViewModel>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Contato com ${widget.professionalName}'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             // Seção 1: Informações do Profissional
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: <Widget>[
//                     if (widget.photoUrl != null)
//                       CircleAvatar(
//                         radius: 40,
//                         backgroundImage: NetworkImage(widget.photoUrl!),
//                       )
//                     else
//                       const CircleAvatar(
//                         radius: 40,
//                         child: Icon(Icons.person, size: 40),
//                       ),
//                     const SizedBox(height: 8.0),
//                     Text(
//                       widget.professionalName,
//                       style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
//                       textAlign: TextAlign.center,
//                     ),
//                     Text(
//                       widget.mainService,
//                       style: TextStyle(color: Colors.grey[600]),
//                       textAlign: TextAlign.center,
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         const Icon(Icons.star, color: Colors.amber),
//                         const SizedBox(width: 4.0),
//                         Text(widget.rating.toStringAsFixed(1)),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16.0),

//             // Seção 2: Opções de Contato
//             const Text(
//               'Entre em Contato',
//               style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8.0),
//             if (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty)
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.phone),
//                 label: Text('Ligar para ${widget.phoneNumber}'),
//                 onPressed: () => {} //_launchUrl('tel:${widget.phoneNumber}'),
//               ),
//             if (widget.whatsappNumber != null && widget.whatsappNumber!.isNotEmpty)
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.whatshot), // Ou um ícone personalizado do WhatsApp
//                 label: Text('Enviar WhatsApp para ${widget.whatsappNumber}'),
//                 onPressed: () => {} //_launchUrl('whatsapp://send?phone=${widget.whatsappNumber}'),
//               ),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.message),
//               label: const Text('Mensagem no App'),
//               onPressed: () {
//                 // Adicionar lógica para abrir a tela de mensagem no app
//                 print('Abrir mensagem no App');
//               },
//             ),
//             const SizedBox(height: 16.0),

//             // Seção 3: Solicitação de Serviço Detalhada (Opcional)
//             const Text(
//               'Precisa de mais detalhes?',
//               style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8.0),
//             DropdownButtonFormField(
//               value: _selectedService,
//               items: [
//                 DropdownMenuItem(
//                   value: widget.mainService,
//                   child: Text(widget.mainService),
//                 ),
//                 // Se você ainda quiser permitir a troca de serviço nesta tela,
//                 // adicione os outros serviços à lista _services e mapeie aqui.
//                 // Caso contrário, pode remover o DropdownButtonFormField e usar apenas um Text mostrando o serviço.
//               ],
//               onChanged: (value) {
//                 setState(() {
//                   _selectedService = value.toString();
//                 });
//               },
//               decoration: const InputDecoration(
//                 labelText: 'Tipo de Serviço',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextFormField(
//               controller: _descriptionController,
//               decoration: const InputDecoration(
//                 labelText: 'Descreva o problema',
//                 border: OutlineInputBorder(),
//               ),
//               maxLines: 3,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Por favor, descreva o serviço necessário';
//                 }
//                 return null;
//               },
//               onChanged: (_) => serviceViewModel.resetError(),
//             ),
//             const SizedBox(height: 20),
//             TextFormField(
//               controller: _addressController,
//               decoration: const InputDecoration(
//                 labelText: 'Endereço',
//                 border: OutlineInputBorder(),
//               ),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Por favor, informe o endereço';
//                 }
//                 return null;
//               },
//               onChanged: (_) => serviceViewModel.resetError(),
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: serviceViewModel.isLoading
//                   ? null
//                   : () => _submitRequest(serviceViewModel),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               child: serviceViewModel.isLoading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text('Enviar Solicitação Detalhada'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _submitRequest(ServiceViewModel serviceViewModel) async {
//     if (_formKey.currentState!.validate()) {
//       final request = ServiceEntity(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         clientId: '', // Você precisará obter o ID do cliente logado
//         professionalId: '', // Você precisará obter o ID do profissional selecionado
//         serviceType: _selectedService,
//         description: _descriptionController.text,
//         address: _addressController.text,
//         requestDate: DateTime.now(),
//         status: 'pending',
//       );

//       await serviceViewModel.createServiceRequestWithCallback(
//         request,
//         onSuccess: () {
//           if (mounted) {
//             Navigator.pop(context);
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Solicitação enviada com sucesso!')),
//             );
//           }
//         },
//         onError: (error) {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Erro: $error')),
//             );
//           }
//         },
//       );
//     }
//   }
// }
