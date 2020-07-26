## Command Line Interface

```
Commands:
  appifier build {RECIPE}  # Build
  appifier help [COMMAND]  # Describe available commands or one specific command
```

## Configuration 

### integration config

Sample config to override ``*.desktop`` files:

```yaml
# ~/.config/appifier/integration.yml
---
RubyMine:
  desktop:
    override:
      'Desktop Entry':
        Icon: rubymine
Mailspring:
  desktop:
    override:
      'Desktop Entry':
        Icon: mailspring
```

