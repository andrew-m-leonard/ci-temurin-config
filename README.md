# Eclipse Temurin Pipeline Configurations

This repository contains the JSON-format pipeline configurations for Eclipse Temurin OpenJDK builds. These configurations are used by the [ci-adoptium-pipelines](https://github.com/adoptium/ci-adoptium-pipelines) build system.

## 📋 Overview

This repository implements the **code/config separation** pattern, where:
- **Pipeline code** lives in [`ci-adoptium-pipelines`](https://github.com/adoptium/ci-adoptium-pipelines)
- **Pipeline configuration** lives here in `ci-temurin-config`

This separation allows:
- ✅ Independent versioning of code and configuration
- ✅ Temurin-specific configurations without affecting pipeline code
- ✅ Easy testing with different configurations
- ✅ Clear ownership boundaries

## 📁 Repository Structure

```
ci-temurin-config/
├── configurations/              # JSON configuration files
│   ├── jdk8u_pipeline_config.json
│   ├── jdk11u_pipeline_config.json
│   ├── jdk17u_pipeline_config.json
│   ├── jdk21u_pipeline_config.json
│   └── ...
├── convert-all-configs.sh      # Batch conversion tool
└── README.md                   # This file
```

## 🎯 Configuration Files

### Available Configurations

| JDK Version | Configuration File | Status |
|-------------|-------------------|--------|
| JDK 8u | `jdk8u_pipeline_config.json` | ✅ Active |
| JDK 11u | `jdk11u_pipeline_config.json` | ✅ Active |
| JDK 17u | `jdk17u_pipeline_config.json` | ✅ Active |
| JDK 21u | `jdk21u_pipeline_config.json` | ✅ Active |
| JDK 22u | `jdk22u_pipeline_config.json` | ✅ Active |
| JDK 23u | `jdk23u_pipeline_config.json` | ✅ Active |
| JDK 24u | `jdk24u_pipeline_config.json` | 🔄 Development |
| JDK 25u | `jdk25u_pipeline_config.json` | 🔄 Development |
| JDK 26u | `jdk26u_pipeline_config.json` | 🔄 Development |
| JDK 27 | `jdk27_pipeline_config.json` | 🔄 Development |

### Configuration Format

Each configuration file follows this JSON schema:

```json
{
  "version": "jdk21u",
  "scmReference": "jdk21u",
  "buildConfigurations": {
    "x64Linux": {
      "os": "linux",
      "arch": "x64",
      "additionalNodeLabels": "centos6&&build",
      "test": "default",
      "dockerImage": "adoptopenjdk/centos6_build_image",
      "dockerFile": "pipelines/build/dockerFiles/cuda.dockerfile",
      "configureArgs": "--enable-unlimited-crypto --with-zlib=system",
      "buildArgs": "--create-sbom"
    },
    "x64Mac": {
      "os": "mac",
      "arch": "x64",
      "additionalNodeLabels": "macos",
      "test": "default",
      "configureArgs": "--enable-unlimited-crypto"
    }
  },
  "targetConfigurations": [
    "x64Linux",
    "x64Mac",
    "x64Windows",
    "aarch64Linux",
    "aarch64Mac"
  ]
}
```

### Key Fields

- **`version`**: JDK version identifier (e.g., "jdk21u")
- **`scmReference`**: Git branch/tag for OpenJDK source
- **`buildConfigurations`**: Platform-specific build settings
  - **`os`**: Operating system (linux, mac, windows, aix)
  - **`arch`**: Architecture (x64, aarch64, ppc64, s390x)
  - **`configureArgs`**: Arguments for OpenJDK configure script
  - **`buildArgs`**: Arguments for make-adopt-build-farm.sh
  - **`dockerImage`**: Docker image for containerized builds
  - **`test`**: Test configuration (default, or custom test list)
- **`targetConfigurations`**: List of platforms to build

## 🚀 Usage

### With Jenkins

The Jenkins pipeline automatically loads configurations from this repository:

```groovy
parameters {
    string(
        name: 'CONFIG_REPO_URL',
        defaultValue: 'https://github.com/adoptium/ci-temurin-config.git',
        description: 'Configuration repository URL'
    )
    string(
        name: 'CONFIG_REPO_BRANCH',
        defaultValue: 'main',
        description: 'Configuration repository branch'
    )
}
```

### Local Testing

Test configurations locally using `run-pipeline.py`:

```bash
# Clone both repositories
git clone https://github.com/adoptium/ci-adoptium-pipelines.git
git clone https://github.com/adoptium/ci-temurin-config.git

# Run pipeline with Temurin config
cd ci-adoptium-pipelines
python3 run-pipeline.py \
  --config ../ci-temurin-config/configurations/jdk21u_pipeline_config.json \
  --platform x64Mac \
  --variant temurin
```

### Testing Configuration Changes

Before committing configuration changes:

1. **Validate JSON syntax**:
```bash
jq empty configurations/jdk21u_pipeline_config.json
```

2. **Test locally**:
```bash
python3 ../ci-adoptium-pipelines/run-pipeline.py \
  --config configurations/jdk21u_pipeline_config.json \
  --platform x64Linux \
  --variant temurin
```

3. **Run in Jenkins** (test branch):
   - Create feature branch
   - Update `CONFIG_REPO_BRANCH` parameter to your branch
   - Run test build

## 🔄 Migration from Groovy

This repository was created by converting legacy Groovy configurations to JSON format.

### Conversion Process

The configurations were converted using the batch conversion tool:

```bash
./convert-all-configs.sh
```

This tool:
1. Reads Groovy config files from `ci-jenkins-pipelines`
2. Parses build configurations
3. Generates JSON files
4. Validates output

### Manual Review Required

After conversion, each configuration should be reviewed for:
- ✅ Nested map structures
- ✅ Test configurations
- ✅ Docker settings
- ✅ Variant-specific values
- ✅ Platform-specific overrides

## 📝 Making Changes

### Adding a New Platform

1. Edit the relevant `jdkNN_pipeline_config.json`
2. Add new platform to `buildConfigurations`:

```json
{
  "buildConfigurations": {
    "aarch64Windows": {
      "os": "windows",
      "arch": "aarch64",
      "additionalNodeLabels": "windows&&arm64",
      "configureArgs": "--enable-unlimited-crypto"
    }
  },
  "targetConfigurations": [
    "aarch64Windows"
  ]
}
```

3. Test locally
4. Create pull request

### Modifying Build Arguments

1. Locate platform in configuration file
2. Update `configureArgs` or `buildArgs`:

```json
{
  "x64Linux": {
    "configureArgs": "--enable-unlimited-crypto --with-zlib=system --with-freetype=bundled"
  }
}
```

3. Test changes
4. Create pull request

### Adding Test Configurations

Test configurations can be simple or complex:

**Simple (default tests)**:
```json
{
  "test": "default"
}
```

**Complex (build-type specific)**:
```json
{
  "test": {
    "nightly": ["sanity.openjdk", "sanity.system"],
    "weekly": ["extended.openjdk", "extended.system"],
    "release": ["sanity.openjdk", "extended.openjdk"]
  }
}
```

## 🔐 Security

### What Goes in This Repository

✅ **Safe to include**:
- Platform configurations
- Build arguments
- Docker image names
- Test configurations
- Node labels

❌ **Never include**:
- Credentials or passwords
- API keys or tokens
- Private URLs
- Signing certificates
- Proprietary information

**Note**: Even though this is a public repository, sensitive values should be managed through Jenkins credentials, not configuration files.

## 🤝 Contributing

### Pull Request Process

1. **Create feature branch**:
```bash
git checkout -b feature/add-riscv64-support
```

2. **Make changes** to configuration files

3. **Validate**:
```bash
# JSON syntax
jq empty configurations/*.json

# Local test
python3 ../ci-adoptium-pipelines/run-pipeline.py \
  --config configurations/jdk21u_pipeline_config.json \
  --platform x64Linux \
  --variant temurin
```

4. **Commit**:
```bash
git add configurations/
git commit -m "feat(jdk21u): add RISC-V 64 support"
```

5. **Push and create PR**:
```bash
git push origin feature/add-riscv64-support
```

### Commit Message Format

Follow conventional commits:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New platform or feature
- `fix`: Bug fix in configuration
- `docs`: Documentation changes
- `refactor`: Configuration restructuring
- `test`: Test configuration changes

**Examples**:
```
feat(jdk21u): add aarch64 Windows support

Add build configuration for Windows on ARM64.
Includes Docker image and configure args.

Closes #123
```

```
fix(jdk17u): correct macOS configure args

Remove deprecated --with-freetype flag that
causes build failures on macOS 13+.

Fixes #456
```

## 📚 Related Documentation

- [ci-adoptium-pipelines](https://github.com/adoptium/ci-adoptium-pipelines) - Pipeline implementation
- [CODE_CONFIG_SEPARATION.md](https://github.com/adoptium/ci-adoptium-pipelines/blob/main/CODE_CONFIG_SEPARATION.md) - Architecture pattern
- [CONFIGURATION_GUIDE.md](https://github.com/adoptium/ci-adoptium-pipelines/blob/main/CONFIGURATION_GUIDE.md) - Configuration schema
- [Adoptium Documentation](https://adoptium.net/docs/) - General Adoptium docs

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/adoptium/ci-temurin-config/issues)
- **Discussions**: [GitHub Discussions](https://github.com/adoptium/ci-temurin-config/discussions)
- **Slack**: [Adoptium Slack](https://adoptium.net/slack)
- **Mailing List**: [adoptium-dev](https://mail.openjdk.org/mailman/listinfo/adoptium-dev)

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Eclipse Adoptium community
- Original ci-jenkins-pipelines contributors
- All configuration maintainers

---

**Maintained by the Eclipse Adoptium Infrastructure Team**

*Making OpenJDK builds configurable and maintainable.*