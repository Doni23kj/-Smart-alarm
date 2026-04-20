# pyright: reportMissingImports=false, reportUndefinedVariable=false
from django.contrib.auth import get_user_model
from rest_framework import status
from rest_framework.test import APITestCase


User = get_user_model()


class UserAuthApiTests(APITestCase):
    def test_register_returns_created_user(self):
        response = self.client.post(
            '/api/register/',
            {
                'username': 'dani',
                'email': 'dani@example.com',
                'phone': '+996700123456',
                'password': 'secret123',
                'confirm_password': 'secret123',
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(User.objects.filter(username='dani').exists())

    def test_login_with_email_returns_tokens_and_user(self):
        User.objects.create_user(
            username='dani',
            email='dani@example.com',
            password='secret123',
        )

        response = self.client.post(
            '/api/token/',
            {'username': 'dani@example.com', 'password': 'secret123'},
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access', response.data)
        self.assertIn('refresh', response.data)
        self.assertEqual(response.data['user']['username'], 'dani')

    def test_profile_can_be_updated_with_avatar(self):
        user = User.objects.create_user(
            username='dani',
            email='dani@example.com',
            password='secret123',
        )
        self.client.force_authenticate(user=user)

        response = self.client.patch(
            '/api/profile/',
            {
                'phone': '+996700123456',
                'avatar': 'data:image/png;base64,ZmFrZQ==',
            },
            format='json',
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        user.refresh_from_db()
        self.assertEqual(user.phone, '+996700123456')
        self.assertEqual(user.avatar, 'data:image/png;base64,ZmFrZQ==')
