# 🎬 Como Ajustar a Velocidade das Animações

## ⚙️ Ajuste Manual no Godot (Recomendado)

As velocidades das animações devem ser ajustadas diretamente no **SpriteFrames** resource no Godot Editor.

### 📋 Passo a Passo:

1. **Abra o Player.tscn** no Godot Editor
2. **Selecione o nó `AnimatedSprite2D2`**
3. No Inspector, encontre **"Sprite Frames"** e clique no resource
4. Isso abrirá o editor de **SpriteFrames**
5. Para cada animação, ajuste a propriedade **"Speed"**:

### 🎯 Valores Recomendados de FPS (Frames Por Segundo):

- **Idle**: 10-15 FPS (animação suave e relaxada)
- **Walk**: 12-15 FPS (caminhada natural)
- **Run**: 15-20 FPS (corrida rápida)
- **Jump**: 8-12 FPS (pulo pode ser um pouco mais lento)
- **Fall**: 8-12 FPS (queda similar ao pulo)
- **Attack**: 15-20 FPS (ataque rápido e dinâmico)

### 💡 Dicas:

- **FPS mais alto** = animação mais rápida
- **FPS mais baixo** = animação mais lenta
- Teste diferentes valores até encontrar o que parece mais natural
- Animações de movimento (walk, run) geralmente precisam de FPS mais alto
- Animações de ação (attack) também precisam ser rápidas para parecerem dinâmicas

### 🔧 Como Ajustar:

1. No editor de SpriteFrames, selecione uma animação (ex: "idle")
2. No painel inferior, você verá a propriedade **"Speed"**
3. Ajuste o valor (ex: 10.0, 12.0, 15.0, etc.)
4. Repita para todas as animações
5. Teste no jogo para ver como ficou

### ⚠️ Nota Importante:

O código tenta ajustar as velocidades automaticamente, mas o método `set_animation_speed()` pode não funcionar corretamente em runtime. Por isso, é melhor ajustar manualmente no Godot Editor.

## 🎮 Testando as Velocidades

Após ajustar:
1. Execute o jogo
2. Observe a animação idle (parado)
3. Mova o personagem para ver walk/run
4. Pule para ver jump
5. Ataque para ver attack
6. Ajuste os valores conforme necessário

## 📊 Valores de Referência:

Se você já ajustou e funcionou bem, anote os valores que usou para referência futura!




