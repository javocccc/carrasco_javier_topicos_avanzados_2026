--1
/* 
Modelo NoSQL para curso_topicos
Colección: clientes
Se embeben Pedidos y DetallesPedidos dentro del documento del cliente
Se embeben datos de Productos en Detalles para evitar consultas adicionales
Motivo: reducir JOINs y mejorar rendimiento en lecturas frecuentes
Nota: si los productos cambian mucho, conviene colección separada
*/
{
  "ClienteID": 1,
  "Nombre": "Juan Pérez",
  "Ciudad": "Santiago",
  "FechaNacimiento": "1990-05-15",
  "Pedidos": [
    {
      "PedidoID": 101,
      "TotalPedido": 2272.5,
      "FechaPedido": "2025-03-01",
      "Detalles": [
        { "ProdID": 1, "NombreProducto": "Laptop", "PrecioUnit": 1200, "Cant": 2 },
        { "ProdID": 2, "NombreProducto": "Mouse",  "PrecioUnit": 25,   "Cant": 5 }
      ]
    }
  ]
}

--2
--clientes de una ciudad específica
db.clientes.find(
  { "Ciudad": "Santiago" },
  { "Nombre": 1, "Ciudad": 1, "_id": 0 }
);

--total de unidades vendidas por producto
db.clientes.aggregate([
  { $unwind: "$Pedidos" },
  { $unwind: "$Pedidos.Detalles" },
  {
    $group: {
      _id: "$Pedidos.Detalles.NombreProducto",
      UnidadesVendidas: { $sum: "$Pedidos.Detalles.Cant" }
    }
  }
]);
