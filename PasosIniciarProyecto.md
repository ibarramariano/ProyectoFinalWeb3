
1. Importa tus Extensiones de VS Code (Se puede usar VS code ignorar los pasos de Kiro e instalar directo  las extensiones Nomic Foundation, Prettier - Code formatter)

Kiro es compatible con el ecosistema de extensiones de VS Code. Instala estas herramientas clave desde su mercado de extensiones para habilitar Solidity:
• Solidity (de Juan Blanco o Nomic Foundation): Proporciona resaltado de sintaxis, autocompletado inteligente (IntelliSense) y compilación básica.
• Prettier - Code formatter: Mantiene el formato de tu código limpio y alineado automáticamente al guardar.

2. Configura tu Entorno Web3 con Foundry (Solución a errores de Windows)

Los agentes de IA de Kiro necesitan herramientas locales instaladas para compilar y validar el código que generan.
Dado que CMD y PowerShell nativos de Windows no son compatibles con el instalador de Foundry, debes utilizar Git Bash dentro de Kiro y corregir las rutas del sistema siguiendo estos pasos exactos:
1. Abre la terminal de Kiro (Ctrl + \``) y asegúrate de cambiar el perfil de la terminal a **Git Bash** (en el menú desplegable junto al botón +`).
2. Crea el archivo de configuración de Git Bash (necesario en Windows si te da el error No such file or directory):bash
touch ~/.bashrc

3. Agrega la ruta correcta de Foundry al PATH:bash
echo 'export PATH="$PATH:$HOME/.foundry/bin"' >> ~/.bashrc

4. Aplica los cambios en la terminal:bash
source ~/.bashrc

5. Ejecuta el instalador oficial de Foundry (Asegúrate de usar la URL de Foundry y no la de Paradigm general):bash
curl -L https://foundry.paradigm.xyz | bash

6. Ejecuta el actualizador de Foundry:
	• Si al escribir foundryup te dice command not found, búscalo directamente con su ruta absoluta en Windows corriendo esto:bash
/c/Users/admin/.foundry/bin/foundryup
Usa el código con precaución.
	• Una vez finalizada la descarga, vuelve a aplicar los cambios del PATH por seguridad:bash
export PATH="$PATH:/c/Users/admin/.foundry/bin"

7. Inicializa tu proyecto en tu carpeta de trabajo (proyectoFinalWeb3):bash
forge init --force

(Usamos --force para evitar conflictos si la carpeta ya contenía archivos previos).
8. Verifica la instalación: Compila el proyecto inicial ejecutando:bash
forge build


3. Adapta las "Specs" para los Agentes de Kiro

Para aprovechar el desarrollo agéntico de Kiro (que es su verdadera ventaja sobre el VS Code tradicional), debes darle instrucciones claras en la carpeta de especificaciones de tu proyecto:
• Define un archivo Markdown (.md): Describe detalladamente las funciones que quieres que tenga tu contrato inteligente (por ejemplo: "Crear un token ERC-20 con funciones de pausa y quemado").
• Configura los comandos de validación: Indica al agente de Kiro que utilice forge build como comando de prueba. De esta forma, la IA sabrá de manera autónoma si el código de Solidity que escribió compila correctamente o si debe corregir errores de sintaxis antes de dar la tarea por terminada.

4. Sincroniza tus Ajustes Personales (Opcional)

Si quieres arrastrar toda tu configuración estética y operativa desde tu VS Code tradicional:
• Copia el contenido de tu archivo settings.json actual en VS Code.
• Abre la paleta de comandos en Kiro (Ctrl + Shift + P o Cmd + Shift + P), busca Preferences: Open User Settings (JSON) y pega tu configuración allí para clonar tus atajos de teclado, temas visuales y fuentes.
