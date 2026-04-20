# pyright: reportUndefinedVariable=false
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from .models import User


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    confirm_password = serializers.CharField(write_only=True)
    avatar = serializers.CharField(required=False, allow_blank=True)

    class Meta:
        model = User
        fields = [
            'id',
            'username',
            'email',
            'phone',
            'avatar',
            'password',
            'confirm_password',
        ]

    def validate(self, attrs):
        if attrs['password'] != attrs['confirm_password']:
            raise serializers.ValidationError({'confirm_password': 'Passwords do not match'})
        if len(attrs['password']) < 6:
            raise serializers.ValidationError({'password': 'Password must be at least 6 characters long'})
        if User.objects.filter(email=attrs.get('email', '')).exists():
            raise serializers.ValidationError({'email': 'A user with this email already exists'})
        return attrs

    def create(self, validated_data):
        validated_data.pop('confirm_password')
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email', ''),
            phone=validated_data.get('phone', ''),
            avatar=validated_data.get('avatar', ''),
            password=validated_data['password']
        )
        return user


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'phone', 'avatar']


class ProfileUpdateSerializer(serializers.ModelSerializer):
    avatar = serializers.CharField(required=False, allow_blank=True)

    class Meta:
        model = User
        fields = ['username', 'email', 'phone', 'avatar']

    def validate_username(self, value):
        queryset = User.objects.exclude(pk=self.instance.pk)
        if queryset.filter(username=value).exists():
            raise serializers.ValidationError('Пользователь с таким именем уже существует')
        return value

    def validate_email(self, value):
        queryset = User.objects.exclude(pk=self.instance.pk)
        if value and queryset.filter(email__iexact=value).exists():
            raise serializers.ValidationError('Пользователь с таким email уже существует')
        return value


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    username_field = 'username'

    def validate(self, attrs):
        login_value = attrs.get('username', '').strip()
        password = attrs.get('password', '')

        if '@' in login_value:
            user = User.objects.filter(email__iexact=login_value).first()
            if user is None:
                raise serializers.ValidationError({
                    'detail': 'No active account found with the given credentials'
                })
            attrs['username'] = user.username

        data = super().validate(attrs)
        data['user'] = UserSerializer(self.user).data
        return data
