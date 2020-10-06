## Command Line Interface

```
Commands:
  appifier build {RECIPE}       # Build given recipe
  appifier config               # Display config
  appifier help [COMMAND]       # Describe available commands or one specific command
  appifier list [PATTERN]       # List builds based on app name
  appifier uninstall {PATTERN}  # Uninstall
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

## About recipe variations

Recipe can have variations, examples:

* ``ffmpeg`` and ``ffmpeg_git``
* ``rubymine`` and ``rubymine_eap``

In this case, integration SHOULD produce the same result,
on __desktop file name__ and __executable__, for both of them.
As a result, it is a transparent experience to switch from variations.
