# pyright: reportMissingImports=false, reportUndefinedVariable=false
from datetime import time

from django.contrib.auth import get_user_model
from rest_framework import status
from rest_framework.test import APITestCase

from .models import Alarm


User = get_user_model()


class AlarmApiTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username='owner',
            email='owner@example.com',
            password='secret123',
        )
        self.other_user = User.objects.create_user(
            username='other',
            email='other@example.com',
            password='secret123',
        )

    def test_authenticated_user_can_create_alarm(self):
        self.client.force_authenticate(user=self.user)

        response = self.client.post(
            '/api/alarms/',
            {
                'time': '07:30:00',
                'label': 'Work',
                'is_active': True,
                'task_type': 'math',
                'difficulty': 'medium',
                'volume': 80,
                'attempts': 3,
                'repeat_days': [0, 1, 2],
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Alarm.objects.count(), 1)
        self.assertEqual(Alarm.objects.first().user, self.user)

    def test_user_sees_only_own_alarms(self):
        Alarm.objects.create(
            user=self.user,
            time=time(7, 0),
            label='Mine',
        )
        Alarm.objects.create(
            user=self.other_user,
            time=time(8, 0),
            label='Not mine',
        )

        self.client.force_authenticate(user=self.user)
        response = self.client.get('/api/alarms/')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]['label'], 'Mine')
