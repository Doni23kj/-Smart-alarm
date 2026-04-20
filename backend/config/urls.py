# pyright: reportCallIssue=false
from django.contrib import admin
from django.urls import path, include
from drf_spectacular.views import (
    SpectacularAPIView,
    SpectacularSwaggerView,
)

from .views import health_check

urlpatterns = [
    path('admin/', admin.site.urls),

    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/swagger/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger'),
    path('api/health/', health_check, name='health_check'),
    path('api/', include('apps.users.urls')),
    path('api/alarms/', include('apps.alarms.urls')),
]
