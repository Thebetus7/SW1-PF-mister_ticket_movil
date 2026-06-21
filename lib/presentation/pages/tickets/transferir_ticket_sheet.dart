import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/mis_ticket_model.dart';
import '../../../data/models/fan_usuario_model.dart';
import '../../state/amistad_provider.dart';
import '../../state/compra_provider.dart';

class TransferirTicketSheet extends StatefulWidget {
  final MisTicketModel ticket;

  const TransferirTicketSheet({super.key, required this.ticket});

  @override
  State<TransferirTicketSheet> createState() => _TransferirTicketSheetState();
}

class _TransferirTicketSheetState extends State<TransferirTicketSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AmistadProvider>(context, listen: false).loadFans();
    });
  }

  Future<void> _confirmarTransferencia(FanUsuarioModel fan) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161626),
        title: const Text('Confirmar transferencia', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Transferir el ticket de "${widget.ticket.eventoNombre}" a ${fan.username}?\n\n'
          'Solo se permite una transferencia. El receptor no podrá volver a transferirlo.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C6FF7)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Transferir'),
          ),
        ],
      ),
    );

    if (confirmado != true || !mounted) return;

    final provider = Provider.of<AmistadProvider>(context, listen: false);
    final compraProvider = Provider.of<CompraProvider>(context, listen: false);

    final ok = await provider.transferirTicket(widget.ticket.id, fan.id);
    if (!mounted) return;

    if (ok) {
      await compraProvider.loadMisTickets();
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ticket transferido a ${fan.username}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Error al transferir'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF7C6FF7);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF161626),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Transferir ticket a un fan',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            widget.ticket.eventoNombre,
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona un usuario fan de la plataforma',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
          ),
          const SizedBox(height: 16),
          Consumer<AmistadProvider>(
            builder: (context, provider, _) {
              if (provider.isLoadingFans) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF7C6FF7))),
                );
              }

              if (provider.fans.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No hay otros usuarios fan registrados.',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.fans.length,
                  itemBuilder: (context, index) {
                    final fan = provider.fans[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      leading: CircleAvatar(
                        backgroundColor: themeColor.withOpacity(0.2),
                        child: Text(
                          fan.username.isNotEmpty ? fan.username[0].toUpperCase() : '?',
                          style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(fan.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        'Usuario fan',
                        style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 11),
                      ),
                      trailing: provider.isTransferring
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7C6FF7)),
                            )
                          : Icon(Icons.chevron_right_rounded, color: themeColor),
                      onTap: provider.isTransferring
                          ? null
                          : () => _confirmarTransferencia(fan),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
