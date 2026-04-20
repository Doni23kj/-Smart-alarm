from drf_spectacular.utils import extend_schema, inline_serializer
from rest_framework import serializers
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response


health_check_response = inline_serializer(
    name='HealthCheckResponse',
    fields={
        'status': serializers.CharField(),
        'service': serializers.CharField(),
    },
)


@extend_schema(responses=health_check_response)
@api_view(["GET"])
@permission_classes([AllowAny])
def health_check(request):
    return Response(
        {
            "status": "ok",
            "service": "Smart Alarm API",
        }
    )
