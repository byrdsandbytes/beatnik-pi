# Snapserver Default Volume

Snapserver assigns newly discovered Snapclients an initial volume of 30%. This
is configured in `/etc/snapserver.conf`:

```ini
[streaming_client]
initial_volume = 30
```

Changing this setting affects new clients only. Existing clients retain their
saved volume; change it using a Snapcast controller.