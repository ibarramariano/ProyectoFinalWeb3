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

### 1. Instalar Foundry

```powershell
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 2. Ejecutar el conjunto de pruebas

```powershell
cd E:\repos\ProyectoFinalWeb3
& "C:\Users\admin\.foundry\bin\forge.exe" test
```

### 3. Deploy a una public EVM network

```powershell
cd E:\repos\ProyectoFinalWeb3
$env:SEPOLIA_RPC_URL = "https://sepolia.infura.io/v3/<your-key>"
$env:PROJECT_OWNER = "0x..."
$env:AUDITOR_1 = "0x..."
$env:AUDITOR_2 = "0x..."
$env:AUDITOR_3 = "0x..."
$env:PRIVATE_KEY = "0x..."

& "C:\Users\admin\.foundry\bin\forge.exe" script script/DeployPublicContracts.s.sol --rpc-url $env:SEPOLIA_RPC_URL --broadcast --private-key $env:PRIVATE_KEY
```

### 4. solo para Local development

```powershell
cd E:\repos\ProyectoFinalWeb3
& "C:\Users\admin\.foundry\bin\anvil.exe" --host 127.0.0.1 --port 8545
```

### 5. Run frontend demo

```powershell
cd E:\repos\ProyectoFinalWeb3\frontend
$env:PATH += ';C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Microsoft\VisualStudio\NodeJs'
npm install
npm run dev -- --host 0.0.0.0
```

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
