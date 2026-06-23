import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Pantalla WebView que carga la URL de pago de Libelula.
///
/// Retorna `true` via [Navigator.pop] cuando detecta que Libelula
/// redirige al deep-link `miapp://pago-completado`, lo que indica
/// que el usuario completo el pago exitosamente.
///
/// Retorna `false` (o null) si el usuario cierra la pantalla sin pagar.
class LibelulaWebViewScreen extends StatefulWidget {
  final String url;

  const LibelulaWebViewScreen({super.key, required this.url});

  @override
  State<LibelulaWebViewScreen> createState() => _LibelulaWebViewScreenState();
}

class _LibelulaWebViewScreenState extends State<LibelulaWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  static const _bgColor = Color(0xFF0F0F1A);
  static const _primaryColor = Color(0xFF7C6FF7);

  // Prefijo del deep-link que indica pago exitoso.
  // Debe coincidir con el `url_retorno` enviado al backend y con `_kUrlRetorno`
  // en checkout_page.dart.
  static const _successUrlPrefix = 'miapp://pago-completado';

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(_bgColor)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            // Ignorar errores de cancelacion de navegacion (status -1)
            // que ocurren al interceptar el deep-link
            if (error.errorCode == -1) return;
            if (mounted) {
              setState(() {
                _isLoading = false;
                _errorMessage =
                    'No se pudo cargar la pasarela de pago. '
                    'Verifica tu conexion e intenta de nuevo.';
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // Interceptar el deep-link de retorno antes de que el WebView
            // intente navegarlo (causaria un error de URL desconocida)
            if (request.url.startsWith(_successUrlPrefix)) {
              // El usuario completo el pago: volver con true
              if (mounted) Navigator.of(context).pop(true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<bool> _onWillPop() async {
    // Si el WebView puede ir atras, navega atras dentro del WebView
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false; // No sale de la pantalla
    }
    // Si no hay mas historia, confirmar salida
    final salir = await _confirmarSalida();
    return salir;
  }

  Future<bool> _confirmarSalida() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161626),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancelar pago',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Si cierras esta pantalla, tu pago quedara pendiente. '
          'Tu reserva expira en 15 minutos.',
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Seguir pagando',
                style: TextStyle(color: _primaryColor)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Cancelar',
                style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: _bgColor,
        appBar: AppBar(
          backgroundColor: const Color(0xFF161626),
          elevation: 0,
          title: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _primaryColor.withOpacity(0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline_rounded,
                        color: Colors.greenAccent, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'Libelula Pay',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white70),
            onPressed: () async {
              final salir = await _confirmarSalida();
              if (salir && mounted) Navigator.of(context).pop(false);
            },
          ),
        ),
        body: Stack(
          children: [
            // WebView principal
            if (_errorMessage == null)
              WebViewWidget(controller: _controller)
            else
              _ErrorView(
                message: _errorMessage!,
                onRetry: () {
                  setState(() => _errorMessage = null);
                  _controller.reload();
                },
              ),

            // Indicador de carga superpuesto
            if (_isLoading && _errorMessage == null)
              Container(
                color: _bgColor,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                          color: _primaryColor, strokeWidth: 2.5),
                      SizedBox(height: 16),
                      Text(
                        'Cargando pasarela de pago...',
                        style:
                            TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: Colors.white30, size: 56),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(color: Colors.white60, fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C6FF7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text('Reintentar',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
