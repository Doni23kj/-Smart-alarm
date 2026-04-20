from django.contrib import admin

from .models import Alarm


@admin.register(Alarm)
class AlarmAdmin(admin.ModelAdmin):
    list_display = (
        'id',
        'user',
        'time',
        'label',
        'task_type',
        'difficulty',
        'is_active',
        'updated_at',
    )
    list_filter = ('is_active', 'task_type', 'difficulty')
    search_fields = ('label', 'user__username', 'user__email')
