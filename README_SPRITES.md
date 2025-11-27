# Guia de Integração de Sprites

## Estrutura de Animações Necessária

Para integrar os sprites do personagem, você precisa:

1. **Criar um SpriteFrames resource** no Godot
2. **Importar as imagens** como Textures
3. **Configurar as animações** com os frames corretos

## Animações do Personagem

### Idle (Parado)
- Frames: 2-3 frames de idle
- Velocidade: 0.3s por frame

### Walk (Caminhada)
- Frames: 6-8 frames do ciclo de caminhada
- Velocidade: 0.15s por frame

### Run (Corrida)
- Frames: 6-8 frames do ciclo de corrida
- Velocidade: 0.1s por frame

### Jump (Pulo)
- Frames: 1-2 frames de pulo
- Velocidade: 0.2s por frame

### Fall (Queda)
- Frames: 1-2 frames de queda
- Velocidade: 0.2s por frame

### Attack (Ataque)
- Frames: 5 frames do ataque com faca/espada
- Velocidade: 0.1s por frame

### Draw Weapon (Sacar Arma)
- Frames: 5 frames de sacar a arma
- Velocidade: 0.15s por frame

## Como Adicionar os Sprites

1. No Godot, selecione o Player
2. Adicione um AnimatedSprite2D como filho
3. Crie um novo SpriteFrames resource
4. Importe as imagens e configure as animações
5. O script player.gd será atualizado para usar essas animações


