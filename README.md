# CryptoTracker
## Funcionalidades destacadas
### Alertas
- Se pueden configurar alertas para monitorear el precio de una criptomoneda.
- Hay dos tipos de alertas: `Precio` y `Volatilidad`.
  - `Precio` se activará cuando el precio de la criptomoneda alcance un valor determinado.
  - `Volatilidad` se activará cuando el precio de la criptomoneda cambie en un porcentaje determinado.
- La alerta, una vez creada, mostrará
  - `precio actual de la criptomoneda` ⭕️
  - `target (precio o volatilidad)` 🎯
  - `precio cuando se estableció la alerta` ⏰
  ![Alerta](./readmeAssets/Alerta.png)
- La alerta tiene 3 posibles estados:
  - `Objetivo alcanzado` 🟢
  - `Expirada` 🔴
  - `Activa` 🔵
### Notificaciones
- Opción para la recepción de notificaciones al configurar una alerta.
  ![Activar Notificación](./readmeAssets/EnableNotifications.png)
- Se recibirá una notificación cuando la alerta expire.

### API Key
- Es recomendable configurar una API Key para evitar el límite de peticiones a la API pública de CoinGecko.
- La API Key se guarda de forma segura en Apple Keychain.
- Capacidad para comprobar la validez de la API Key en el apartado de ajustes de la aplicación.

### Gráficos
- Visualizaciones de gráficos de la evolución del precio de cualquier criptomoneda. 
- Hay que especificar el rango de tiempo para la visualización del gráfico.
- Solo se pueden visualizar rangos de tiempo pasados.

### Preferencias
- Opción para cambiar la moneda de visualización de los precios.
- Opción para activar las notificaciones.

<div style="page-break-before: always;"></div>

## Aspectos importantes del desarrollo
### MVVM
- Se ha utilizado el patrón de diseño MVVM para la arquitectura de la aplicación.
  - `Model`: Encargado de la definición y la persistencia de los datos.
  - `View`: Encargado de la presentación de los datos.
  - `ViewModel`: Encargado de la lógica de negocio y la comunicación entre `Model` y `View`.


### Servicios
#### CryptoRetrieveService
- Encargado de la obtención de datos de la API de CoinGecko.
#### NotificationService
- Encargado de la gestión de notificaciones.
### Persistencia
- `SwiftData` para la persistencia de las alertas y las criptomonedas guardadas.
- `Apple Keychain` para la persistencia de la API Key.
- `UserDefaults` para la persistencia de las preferencias de usuario.
### Dependencias
- `KeyChainAccess` para una API simplificada de Apple Keychain.


![Gráfico](./readmeAssets/Charts.png)
![Ajustes](./readmeAssets/Settings.png)