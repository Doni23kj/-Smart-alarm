from rest_framework import viewsets, permissions
from .models import Alarm
from .serializers import AlarmSerializer


class AlarmViewSet(viewsets.ModelViewSet):
    queryset = Alarm.objects.all()
    serializer_class = AlarmSerializer
    permission_classes = [permissions.IsAuthenticated]
    lookup_value_converter = 'int'

    def get_queryset(self):
        return Alarm.objects.filter(user=self.request.user).order_by('-created_at')

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
