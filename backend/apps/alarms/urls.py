from rest_framework.routers import DefaultRouter
from .views import AlarmViewSet

router = DefaultRouter()
router.register(r'', AlarmViewSet, basename='alarms')

urlpatterns = router.urls