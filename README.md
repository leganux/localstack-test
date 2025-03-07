# LocalStack Development Environment

Este ambiente de desarrollo local simula servicios AWS usando LocalStack. Incluye configuración para S3, SES, Secrets Manager, API Gateway, Lambda, DynamoDB, SQS y SNS.

## Prerrequisitos

- Docker
- Docker Compose
- AWS CLI (opcional pero recomendado)
- AWS SDK para tu lenguaje de programación

## Configuración Inicial

1. Inicia el ambiente de LocalStack:
```bash
docker-compose up -d
```

2. Verifica que LocalStack esté funcionando:
```bash
docker ps
docker logs localstack
```

## Credenciales para el SDK

### Configuración Local de AWS

1. Crea o modifica `~/.aws/credentials`:
```ini
[localstack]
aws_access_key_id = test
aws_secret_access_key = test
region = us-east-1
```

2. Configura las variables de entorno en tu aplicación:
```bash
export AWS_PROFILE=localstack
export AWS_ENDPOINT_URL=http://localhost:4566
```

### Ejemplo de Configuración en TypeScript

```typescript
import { S3Client } from '@aws-sdk/client-s3';
import { SecretsManagerClient } from '@aws-sdk/client-secrets-manager';

const awsConfig = {
  endpoint: 'http://localhost:4566',
  region: 'us-east-1',
  credentials: {
    accessKeyId: 'test',
    secretAccessKey: 'test'
  }
};

// Cliente para S3
const s3Client = new S3Client(awsConfig);

// Cliente para Secrets Manager
const secretsClient = new SecretsManagerClient(awsConfig);
```

## Servicios Preconfigurados

### 1. S3
- Bucket: `my-test-bucket`
- Prueba de funcionamiento:
```bash
# Listar buckets
aws --endpoint-url=http://localhost:4566 s3 ls

# Subir un archivo
aws --endpoint-url=http://localhost:4566 s3 cp test.txt s3://my-test-bucket/
```

### 2. Secrets Manager
- Secret Path: `/dev/app/config`
- Contenido del secreto:
```json
{
  "database": "mydb",
  "username": "admin",
  "password": "mypassword"
}
```
- Prueba de funcionamiento:
```bash
# Obtener el valor del secreto
aws --endpoint-url=http://localhost:4566 secretsmanager get-secret-value --secret-id /dev/app/config
```

### 3. DynamoDB
- Tabla: `TestTable`
- Esquema: `id` (String) como clave primaria
- Prueba de funcionamiento:
```bash
# Listar tablas
aws --endpoint-url=http://localhost:4566 dynamodb list-tables

# Insertar un item
aws --endpoint-url=http://localhost:4566 dynamodb put-item \
    --table-name TestTable \
    --item '{"id": {"S": "1"}, "data": {"S": "test"}}'
```

### 4. SQS
- Cola: `test-queue`
- Prueba de funcionamiento:
```bash
# Listar colas
aws --endpoint-url=http://localhost:4566 sqs list-queues

# Enviar mensaje
aws --endpoint-url=http://localhost:4566 sqs send-message \
    --queue-url http://localhost:4566/000000000000/test-queue \
    --message-body "Test message"
```

### 5. SNS
- Tema: `test-topic`
- Prueba de funcionamiento:
```bash
# Listar temas
aws --endpoint-url=http://localhost:4566 sns list-topics
```

### 6. SES
- Email verificado: `noreply@example.com`
- Prueba de funcionamiento:
```bash
# Listar emails verificados
aws --endpoint-url=http://localhost:4566 ses list-verified-email-addresses
```

## Uso de Secrets en tu Aplicación

### TypeScript Example:
```typescript
import { SecretsManagerClient, GetSecretValueCommand } from '@aws-sdk/client-secrets-manager';

async function getSecret() {
  const client = new SecretsManagerClient({
    endpoint: 'http://localhost:4566',
    region: 'us-east-1',
    credentials: {
      accessKeyId: 'test',
      secretAccessKey: 'test'
    }
  });

  try {
    const response = await client.send(
      new GetSecretValueCommand({
        SecretId: '/dev/app/config'
      })
    );
    
    if (response.SecretString) {
      const secret = JSON.parse(response.SecretString);
      return secret;
    }
  } catch (error) {
    console.error('Error al obtener el secreto:', error);
    throw error;
  }
}
```

## Solución de Problemas

1. Si los servicios no son accesibles:
```bash
# Reiniciar LocalStack
docker-compose down
docker-compose up -d

# Verificar logs
docker logs localstack
```

2. Si necesitas limpiar todos los datos:
```bash
# Detener y eliminar volúmenes
docker-compose down -v
# Reiniciar
docker-compose up -d
```

3. Para verificar que los servicios están funcionando:
```bash
# Listar todos los servicios disponibles
aws --endpoint-url=http://localhost:4566 --no-sign-request lambda list-functions
aws --endpoint-url=http://localhost:4566 --no-sign-request s3 ls
aws --endpoint-url=http://localhost:4566 --no-sign-request secretsmanager list-secrets
```

## Notas Importantes

- La región por defecto es `us-east-1`
- Todos los servicios corren en el puerto `4566`
- Credenciales por defecto:
  - Access Key: `test`
  - Secret Key: `test`
- La persistencia está habilitada en el directorio `./volume`

## Consideraciones de Seguridad

Esta configuración es solo para desarrollo local. Nunca uses estas credenciales o configuraciones en un ambiente de producción.
