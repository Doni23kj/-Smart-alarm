from django.conf import settings
from django.db import models


def default_repeat_days():
    return []


class Alarm(models.Model):
    TASK_CHOICES = [
        ('math', 'Math'),
        ('photo', 'Photo'),
        ('logic', 'Logic'),
        ('memory', 'Memory'),
    ]

    DIFFICULTY_CHOICES = [
        ('easy', 'Easy'),
        ('medium', 'Medium'),
        ('hard', 'Hard'),
    ]

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='alarms'
    )
    time = models.TimeField()
    label = models.CharField(max_length=255, blank=True)
    is_active = models.BooleanField(default=True)
    task_type = models.CharField(max_length=20, choices=TASK_CHOICES, default='math')
    difficulty = models.CharField(max_length=20, choices=DIFFICULTY_CHOICES, default='medium')
    volume = models.PositiveIntegerField(default=80)
    attempts = models.PositiveIntegerField(default=3)
    repeat_days = models.JSONField(default=default_repeat_days, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.username} - {self.label or self.time}"
