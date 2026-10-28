# Proyecto Final Web3 - Financiación transparente de la investigación científica

## I. Resumen ejecutivo

Este proyecto propone una solución basada en tecnología *blockchain* para financiar la investigación científica y proyectos de interés público. El objetivo principal es eliminar la opacidad, el control discrecional y los posibles sesgos en la asignación de capital, utilizando contratos inteligentes (*smart contracts*) para automatizar las donaciones, la gobernanza y la liberación de fondos conforme a hitos verificables.

La solución se articula en torno a un modelo de depósito en garantía (*escrow*) transparente, en el que los fondos permanecen bloqueados en un contrato y solo se liberan cuando varios auditores independientes validan el progreso y las pruebas vinculadas a cada hito. Este diseño reduce el riesgo de corrupción, arbitrariedad administrativa y presentación selectiva de resultados.

## II. Relevancia de la tecnología *blockchain* para este problema

El uso de *blockchain* en la financiación científica no es una mera tendencia tecnológica, sino una respuesta estructural a las deficiencias de los sistemas centralizados:

- Eliminación de intermediarios opacos: los fondos no permanecen en cuentas administrativas poco claras, sino que están sujetos a reglas codificadas en contratos inteligentes.
- Transparencia y capacidad de auditoría: cualquier donante, institución o ciudadano puede rastrear cómo se asignan los fondos y qué hitos han sido aprobados.
- Reducción de la corrupción y los sesgos comerciales: el sistema requiere una estructura de gobernanza multifirma (*multi-signature*) y referencias a pruebas inmutables, como los *hashes* de IPFS.
- Rendición de cuentas en tiempo real: los hitos y las votaciones quedan registrados en la cadena (*on-chain*), lo que permite verificar de forma transparente el progreso y la asignación de recursos a lo largo del tiempo.

## III. Planteamiento del problema

La financiación científica suele enfrentarse a desafíos como:
- falta de trazabilidad;
- decisiones discrecionales tomadas por un único administrador;
- divulgación selectiva de resultados;
- dependencia de instituciones centralizadas opacas.

Esta solución aborda dichas debilidades mediante la creación de un mecanismo de gobernanza en el que los fondos solo se liberan si el hito correspondiente cuenta con la aprobación suficiente por parte de auditores independientes y, en una versión ampliada, de validadores externos.

## IV. Valor empresarial y técnico

El sistema propuesto aporta valor en dos niveles:

- Valor empresarial: mejora la confianza entre donantes, instituciones y la sociedad, al tiempo que permite una financiación más resiliente para la investigación.
- Valor técnico: demuestra el uso de patrones seguros de contratos inteligentes, trazabilidad basada en eventos y una lógica de gobernanza aplicada al mundo real dentro de un entorno *blockchain*.

## V. Estructura del repositorio

```text
ProyectoFinalWeb3/
├── contracts/                     # Smart contract source code
│   ├── ScientificFund.sol
│   ├── ScientificFundOracle.sol
│   └── Counter.sol
├── test/                         # Unit tests
│   ├── ScientificFund.t.sol
│   ├── ScientificFundOracle.t.sol
│   └── Counter.t.sol
├── script/                       # Deployment scripts
│   └── ScientificFund.s.sol
├── frontend/                     # Frontend demo
├── lib/                          # Foundry dependencies
├── README.md
├── foundry.toml
├── .gitmodules
└── .gitignore
```

## VI. Smart Contract diseño

### Fondo Científico - ScientificFund
El contrato base implementa la lógica fundamental de financiación:
- gestión de donaciones y depósitos en garantía (escrow)
- establecimiento de hitos
- votación por parte de múltiples auditores
- liberación de fondos sujeta únicamente a la aprobación por mayoría
- eventos públicos para garantizar la transparencia y la trazabilidad

### ScientificFundOracle
La versión extendida añade una capa de validación externa antes de la liberación de los fondos. Esto simula un proceso real de carácter institucional o de validación de datos, mediante el cual se confirma la validez de las pruebas que acreditan el cumplimiento de un hito antes de autorizar el pago final.

Esto demuestra cómo un proyecto puede combinar la gobernanza *on-chain* (en la cadena de bloques) con servicios de verificación externos o *off-chain* (fuera de la cadena).

## VII. Requisitos de ingeniería cumplidos

Este proyecto aborda los requisitos de ingeniería y desarrollo para una solución Web3:

- Seguridad y estructura: uso de `Ownable`, `ReentrancyGuard`, validación de entradas y patrones de «verificaciones-efectos-interacciones» (*checks-effects-interactions*).
- Solidity profesional: variables de estado públicas, errores personalizados, eventos estructurados y gestión optimizada de valores.
- Modularidad: separación clara entre la lógica central de financiación y la extensión basada en oráculos.
- Capacidad de prueba: pruebas unitarias automatizadas mediante Foundry.

# VIII. Conjunto de pruebas

Las pruebas unitarias validan la lógica funcional principal:
- flujo de donaciones
- creación de hitos
- votación para la aprobación o el rechazo
- condiciones de liberación basadas en una votación por mayoría
- flujos de rechazo y aprobación basados ​​en oráculos

## IX. Cómo ejecutar el proyecto

### Requisitos

- Windows, PowerShell y Git.
- Foundry: `forge`, `cast` y `anvil`. En este equipo se instalaron en `C:\Users\admin\.foundry\bin`. Consulta la [guía oficial de Foundry](https://getfoundry.sh/).
- Node.js y npm. Se recomienda administrar Node con [NVM for Windows](https://github.com/coreybutler/nvm-windows):

```powershell
nvm install 22.12.0
nvm use 22.12.0
node --version
npm --version
```

- MetaMask instalado en el mismo navegador donde se abre el frontend.

Este repositorio no tiene un backend HTTP independiente. **Anvil es el nodo EVM local**; Foundry despliega los contratos en ese nodo y el frontend se conecta directamente mediante MetaMask.

### 1. Instalar dependencias y ejecutar pruebas

Ejecuta `npm install` dentro de `frontend`, no en la raíz del repositorio:

```powershell
Set-Location E:\repos\ProyectoFinalWeb3\frontend
npm install
npm run build
```

Las pruebas Solidity se ejecutan desde la raíz:

```powershell
Set-Location E:\repos\ProyectoFinalWeb3
& "$HOME\.foundry\bin\forge.exe" test
```

### 2. Iniciar la blockchain local Anvil

Abre una terminal PowerShell y déjala abierta mientras trabajas:

```powershell
Set-Location E:\repos\ProyectoFinalWeb3
& "$HOME\.foundry\bin\anvil.exe" --host 127.0.0.1 --port 8545
```

Anvil imprime cuentas de prueba, sus direcciones y sus claves privadas. Esas cuentas tienen ETH ficticio local. **Usa sus claves solo en Anvil; nunca en Sepolia, Mainnet o una wallet con fondos reales.** Cada vez que reinicies Anvil sin guardar/restaurar un estado, la blockchain local vuelve a empezar y hay que desplegar de nuevo.

### 3. Desplegar `ScientificFund` en Anvil

Abre una segunda terminal. Para la configuración predeterminada de Anvil, usa la cuenta 0 como owner y las cuentas 1, 2 y 3 como auditores. La clave de ejemplo incluida es la clave determinística pública de la cuenta 0 de Anvil y solo debe usarse en la red local:

```powershell
Set-Location E:\repos\ProyectoFinalWeb3
$env:PROJECT_OWNER = "0xf39Fd00000000000000000000000000"
$env:AUDITOR_1 = "0x700000000000000000000000000008"
$env:AUDITOR_2 = "0x3000000000000000000000000293BC"
$env:AUDITOR_3 = "0x90000000000000000000000000906"

& "$HOME\.foundry\bin\forge.exe" script script/ScientificFund.s.sol:ScientificFundScript --rpc-url http://127.0.0.1:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

Guarda la dirección que Foundry muestra como `Contract Address`. En la configuración actual del frontend, la dirección se define en `frontend/src/contract.js`. Debe coincidir con el despliegue actual. En una instancia limpia de Anvil normalmente es `0x5FbDB2315678afecb367f032d93F642f64180aa3`; si Foundry muestra otra dirección, actualiza `CONTRACT_ADDRESS` con la dirección mostrada, sin los signos `< >` de marcadores de ejemplo.

Puedes comprobar el despliegue desde PowerShell:

```powershell
& "$HOME\.foundry\bin\cast.exe" chain-id --rpc-url http://127.0.0.1:8545
& "$HOME\.foundry\bin\cast.exe" code 0x5FbDB2315678afecb367f032d93F642f64180aa3 --rpc-url http://127.0.0.1:8545
```

El chain ID debe ser `31337` y `cast code` debe devolver bytecode, no `0x`.

### 4. Conectar MetaMask a Anvil

En MetaMask, agrega una red con estos datos:

- Nombre: `Anvil Local`
- RPC: `http://127.0.0.1:8545`
- Chain ID: `31337`
- Moneda: `ETH`

Importa una cuenta de prueba usando la clave privada que Anvil imprimió para esa cuenta. No uses aquí la cuenta de Sepolia. Abre el frontend en el mismo navegador que tiene MetaMask, selecciona `Anvil Local` y pulsa **Conectar MetaMask**.

### 5. Iniciar y usar el frontend

Abre una tercera terminal. El comando usa explícitamente la carpeta del frontend, para que npm encuentre su `package.json`:

```powershell
npm --prefix E:\repos\ProyectoFinalWeb3\frontend run dev -- --host 127.0.0.1
```

Abre la URL que imprime Vite, normalmente <http://127.0.0.1:5173/>. Con MetaMask conectado a Anvil, introduce una cantidad mayor que cero, por ejemplo `0.01`, pulsa **Donar** y confirma la transacción en MetaMask. La recaudación debería actualizarse cuando Anvil confirme la transacción.

Las transacciones locales se consultan en la actividad de MetaMask mientras está seleccionada Anvil; no aparecen en Sepolia Etherscan. Los hitos, votos y algunas cifras de la interfaz son datos de demostración; en este momento la acción conectada al contrato desde el frontend es la donación.

### 6. Anvil y Sepolia son redes diferentes

El frontend descrito arriba apunta a Anvil (`31337`), no a Sepolia (`11155111`). El saldo de una dirección en Sepolia no está disponible en Anvil y viceversa. Para desplegar en Sepolia se necesita una RPC válida, ETH de prueba en Sepolia y una configuración de frontend con la dirección del contrato desplegado en esa red. No reutilices claves de Anvil ni publiques claves privadas o API keys.

Si una clave privada o API key real se compartió por chat o se subió al repositorio, reemplázala; no la guardes en el código ni en variables `VITE_`, porque esas variables se incorporan al bundle del navegador.

### Solución de problemas

- `npm` no encuentra `package.json`: ejecuta npm con `--prefix E:\repos\ProyectoFinalWeb3\frontend` o cambia primero a esa carpeta.
- `missing revert data`: confirma que MetaMask está en `Anvil Local (31337)`, que Anvil sigue ejecutándose y que `CONTRACT_ADDRESS` contiene una dirección desplegada en esa instancia.
- El frontend queda en “Procesando”: confirma que Anvil sigue respondiendo en `http://127.0.0.1:8545`. Si reinicias Anvil, vuelve a desplegar y actualiza la dirección del frontend si cambió.
- MetaMask no muestra la transacción: revisa la actividad con `Anvil Local` seleccionada; una transacción local no aparecerá en el explorador de Sepolia.
- `Failed to decode private key`: pasa una clave hexadecimal completa, sin los caracteres `< >` usados como marcadores. Las claves impresas por Anvil son solo para desarrollo local.

### 7. Despliegue opcional en Sepolia

Este procedimiento es independiente de Anvil y consume ETH de prueba de Sepolia para el gas. Crea una RPC en Alchemy u otro proveedor y usa direcciones de owner/auditores válidas. Define las credenciales solo en la terminal o en un gestor de secretos; no las guardes en el repositorio ni las compartas.

```powershell
Set-Location E:\repos\ProyectoFinalWeb3
$env:SEPOLIA_RPC_URL = "https://eth-sepolia.g.alchemy.com/v2/REEMPLAZA_CON_TU_API_KEY"
$env:PRIVATE_KEY = "REEMPLAZA_CON_LA_CLAVE_DE_UNA_WALLET_DE_PRUEBA"
$env:PROJECT_OWNER = "0xDIRECCION_DEL_OWNER"
$env:AUDITOR_1 = "0xDIRECCION_AUDITOR_1"
$env:AUDITOR_2 = "0xDIRECCION_AUDITOR_2"
$env:AUDITOR_3 = "0xDIRECCION_AUDITOR_3"

& "$HOME\.foundry\bin\forge.exe" script script/DeployPublicContracts.s.sol:DeployPublicContracts --rpc-url $env:SEPOLIA_RPC_URL --broadcast --private-key $env:PRIVATE_KEY
```

Sustituye los textos de ejemplo por valores reales válidos, sin los marcadores explicativos. Anota las direcciones que Foundry devuelve para `ScientificOracle` y `ScientificFundOracle`, y comprueba el bytecode con `cast code` usando la RPC de Sepolia. El frontend descrito en esta guía aún valida la red local `31337`; para usarlo en Sepolia hay que cambiar la configuración de red y la dirección del contrato en el frontend. Nunca uses la clave de prueba predeterminada de Anvil en Sepolia o en una red con valor real.

## X. Roadmap

### Fase 1 - MVP *on-chain*
- Contrato de financiación basado en un mecanismo de depósito en garantía (*escrow*)
- Lógica de aprobación mediante múltiples auditores
- Despliegue y pruebas automatizados

### Fase 2 - Capa de validación científica
- Validación de hitos mediante oráculos
- Mejoras en la gobernanza y soporte para múltiples proyectos
- Integración con referencias probatorias públicas y metadatos en IPFS

### Fase 3 - Producto orientado al usuario
- Panel de control (*dashboard*) más completo
- Integración con monederos (*wallets*) como MetaMask
- Conexión a redes de prueba (*testnets*) públicas

### Fase 4 - Preparación para producción
- Auditoría de seguridad formal
- Despliegue en una red de prueba pública
- Evolución de la gobernanza hacia un modelo de DAO o comité institucional

## XI. Conclusión

Este proyecto demuestra cómo la tecnología *blockchain* puede mejorar la rendición de cuentas en la financiación pública y científica, transformando la gobernanza y la distribución de fondos en reglas transparentes y programables. La implementación combina la seguridad de los contratos inteligentes, la redundancia en la toma de decisiones y la trazabilidad de las evidencias, ofreciendo una base práctica para fomentar la confianza en la financiación de la investigación mediante tecnología *blockchain*.
