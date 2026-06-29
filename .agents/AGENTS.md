# Pautas de Arquitectura de la Aplicación

## Reglas de Arquitectura de Flujo de Datos

1. **Flujo de Datos Limpio**:
   - La **Vista** (UI/Widget) ejecuta eventos o acciones sobre un **Bloc** (o Cubit).
   - El **Bloc** gestiona el estado y llama a un **Repositorio**.
   - El **Repositorio** coordina los datos, llama al **Servicio** correspondiente y mapea/transforma las respuestas crudas del API en entidades o modelos de dominio limpios (como `DoctorModel`).
   - El **Servicio** (por ejemplo, `AppointmentsService`) realiza las peticiones directas de red/HTTP utilizando el cliente HTTP (Dio) y maneja las respuestas HTTP sin transformarlas en modelos de dominio complejos.

2. **Rol del Controlador**:
   - El **Controlador** (ej. clases que actúan como presentadores o controladores locales de UI) solo posee lógica puramente visual o de presentación que no debe mezclarse directamente dentro de la clase del Widget de la Vista (para mantener la vista limpia y declarativa).
   - El **Controlador** no debe realizar llamadas directas a APIs o de red. Debe delegar a los Repositorios/Servicios/Blocs la obtención y mutación de datos de negocio.
