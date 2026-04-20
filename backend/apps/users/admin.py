from django.contrib import admin
from django.contrib.auth.admin import UserAdmin

from .models import User


@admin.register(User)
class SmartAlarmUserAdmin(UserAdmin):
    list_display = ('id', 'username', 'email', 'phone', 'is_staff', 'is_active')
    search_fields = ('username', 'email', 'phone')
    fieldsets = UserAdmin.fieldsets + (
        ('Smart Alarm', {'fields': ('phone', 'avatar')}),
    )
