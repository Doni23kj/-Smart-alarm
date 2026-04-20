from rest_framework import serializers
from .models import Alarm


class AlarmSerializer(serializers.ModelSerializer):
    class Meta:
        model = Alarm
        fields = [
            'id',
            'time',
            'label',
            'is_active',
            'task_type',
            'difficulty',
            'volume',
            'attempts',
            'repeat_days',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']