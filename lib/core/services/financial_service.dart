import 'package:flutter/foundation.dart';
import '../database/database.dart';

/// Modelo para datos financieros
class FinancialData {
  final double totalVentas;
  final double totalCompras;
  final double gananciasBrutas;
  final double gananciasNetas;
  final int totalProductos;
  final int productosConStock;
  final int productosSinStock;
  final double valorInventario;
  final Map<String, double> ventasPorCategoria;
  final List<VentasDiarias> ventasDiarias;
  final List<ProductoMasVendido> productosMasVendidos;

  FinancialData({
    required this.totalVentas,
    required this.totalCompras,
    required this.gananciasBrutas,
    required this.gananciasNetas,
    required this.totalProductos,
    required this.productosConStock,
    required this.productosSinStock,
    required this.valorInventario,
    required this.ventasPorCategoria,
    required this.ventasDiarias,
    required this.productosMasVendidos,
  });
}

/// Modelo para ventas diarias
class VentasDiarias {
  final DateTime fecha;
  final double ventas;
  final double ganancias;
  final int cantidadProductos;

  VentasDiarias({
    required this.fecha,
    required this.ventas,
    required this.ganancias,
    required this.cantidadProductos,
  });
}

/// Modelo para productos más vendidos
class ProductoMasVendido {
  final String nombre;
  final String categoria;
  final int cantidadVendida;
  final double ingresoTotal;

  ProductoMasVendido({
    required this.nombre,
    required this.categoria,
    required this.cantidadVendida,
    required this.ingresoTotal,
  });
}

/// Servicio para análisis financiero y reportes
class FinancialService {
  final AppDatabase _database;

  FinancialService(this._database);

  /// Obtener datos financieros completos
  Future<FinancialData> getFinancialData({
    DateTime? desde,
    DateTime? hasta,
  }) async {
    // Definir fechas por defecto (último mes)
    desde ??= DateTime.now().subtract(const Duration(days: 30));
    hasta ??= DateTime.now();

    // Obtener todos los productos
    final productos = await _database.getAllProducts();

    // Obtener movimientos de stock en el período
    final movimientos = await _database.getStockMovementsByPeriod(desde, hasta);

    // Calcular métricas básicas
    double totalVentas = 0.0;
    double totalCompras = 0.0;

    Map<String, double> ventasPorCategoria = {};
    Map<String, double> ventasPorProducto = {};

    for (var movimiento in movimientos) {
      if (movimiento.type == 'salida') {
        final producto = productos.firstWhere(
          (p) => p.uuid == movimiento.productUuid,
          orElse: () => throw Exception('Producto no encontrado'),
        );

        double ingresoVenta =
            movimiento.quantity.toDouble() * producto.salePrice;
        totalVentas += ingresoVenta;

        // Ventas por categoría
        String categoria = producto.category ?? 'Sin categoría';
        ventasPorCategoria[categoria] =
            (ventasPorCategoria[categoria] ?? 0.0) + ingresoVenta;

        // Conteo de productos vendidos
        ventasPorProducto[producto.name] =
            (ventasPorProducto[producto.name] ?? 0.0) +
            movimiento.quantity.toDouble();
      } else if (movimiento.type == 'entrada') {
        final producto = productos.firstWhere(
          (p) => p.uuid == movimiento.productUuid,
          orElse: () => throw Exception('Producto no encontrado'),
        );

        double costoCompra =
            movimiento.quantity.toDouble() * producto.purchasePrice;
        totalCompras += costoCompra;
      }
    }

    // Calcular ganancias
    double gananciasBrutas = totalVentas - totalCompras;
    double gananciasNetas =
        gananciasBrutas; // Simplificado, sin gastos operativos

    // Estadísticas de inventario
    int productosConStock = productos.where((p) => p.stock > 0).length;
    int productosSinStock = productos.where((p) => p.stock == 0).length;

    double valorInventario = productos.fold(
      0.0,
      (sum, producto) => sum + (producto.stock * producto.purchasePrice),
    );

    // Generar datos de ventas diarias
    List<VentasDiarias> ventasDiarias = await _generateVentasDiarias(
      desde,
      hasta,
      movimientos,
      productos,
    );

    // Generar productos más vendidos
    List<ProductoMasVendido> productosMasVendidos =
        _generateProductosMasVendidos(ventasPorProducto, productos);

    return FinancialData(
      totalVentas: totalVentas,
      totalCompras: totalCompras,
      gananciasBrutas: gananciasBrutas,
      gananciasNetas: gananciasNetas,
      totalProductos: productos.length,
      productosConStock: productosConStock,
      productosSinStock: productosSinStock,
      valorInventario: valorInventario,
      ventasPorCategoria: ventasPorCategoria,
      ventasDiarias: ventasDiarias,
      productosMasVendidos: productosMasVendidos,
    );
  }

  /// Generar datos de ventas diarias
  Future<List<VentasDiarias>> _generateVentasDiarias(
    DateTime desde,
    DateTime hasta,
    List<StockMovement> movimientos,
    List<Product> productos,
  ) async {
    Map<DateTime, VentasDiarias> ventasPorDia = {};

    // Inicializar todos los días con valores cero
    for (
      DateTime fecha = desde;
      fecha.isBefore(hasta.add(const Duration(days: 1)));
      fecha = fecha.add(const Duration(days: 1))
    ) {
      DateTime fechaSinHora = DateTime(fecha.year, fecha.month, fecha.day);
      ventasPorDia[fechaSinHora] = VentasDiarias(
        fecha: fechaSinHora,
        ventas: 0.0,
        ganancias: 0.0,
        cantidadProductos: 0,
      );
    }

    // Procesar movimientos de salida (ventas)
    for (var movimiento in movimientos) {
      if (movimiento.type == 'salida') {
        DateTime fechaMovimiento = DateTime(
          movimiento.createdAt.year,
          movimiento.createdAt.month,
          movimiento.createdAt.day,
        );

        if (ventasPorDia.containsKey(fechaMovimiento)) {
          final producto = productos.firstWhere(
            (p) => p.uuid == movimiento.productUuid,
            orElse: () => throw Exception('Producto no encontrado'),
          );

          double ingresoVenta =
              movimiento.quantity.toDouble() * producto.salePrice;
          double costoVenta =
              movimiento.quantity.toDouble() * producto.purchasePrice;
          double ganancia = ingresoVenta - costoVenta;

          VentasDiarias ventaActual = ventasPorDia[fechaMovimiento]!;
          ventasPorDia[fechaMovimiento] = VentasDiarias(
            fecha: fechaMovimiento,
            ventas: ventaActual.ventas + ingresoVenta,
            ganancias: ventaActual.ganancias + ganancia,
            cantidadProductos:
                ventaActual.cantidadProductos + movimiento.quantity,
          );
        }
      }
    }

    return ventasPorDia.values.toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
  }

  /// Generar lista de productos más vendidos
  List<ProductoMasVendido> _generateProductosMasVendidos(
    Map<String, double> ventasPorProducto,
    List<Product> productos,
  ) {
    List<ProductoMasVendido> productosMasVendidos = [];

    ventasPorProducto.forEach((nombreProducto, cantidadVendida) {
      try {
        final producto = productos.firstWhere(
          (p) => p.name == nombreProducto,
          orElse: () => throw Exception('Producto no encontrado'),
        );

        double ingresoTotal = cantidadVendida * producto.salePrice;

        productosMasVendidos.add(
          ProductoMasVendido(
            nombre: producto.name,
            categoria: producto.category ?? 'Sin categoría',
            cantidadVendida: cantidadVendida.toInt(),
            ingresoTotal: ingresoTotal,
          ),
        );
      } catch (e) {
        debugPrint('Error al procesar producto $nombreProducto: $e');
      }
    });

    // Ordenar por cantidad vendida descendente
    productosMasVendidos.sort(
      (a, b) => b.cantidadVendida.compareTo(a.cantidadVendida),
    );

    // Retornar solo los top 10
    return productosMasVendidos.take(10).toList();
  }

  /// Obtener resumen financiero rápido
  Future<Map<String, double>> getFinancialSummary() async {
    final data = await getFinancialData();

    return {
      'totalVentas': data.totalVentas,
      'gananciasBrutas': data.gananciasBrutas,
      'valorInventario': data.valorInventario,
      'margenGanancia':
          data.totalVentas > 0
              ? (data.gananciasBrutas / data.totalVentas) * 100
              : 0.0,
    };
  }
}
