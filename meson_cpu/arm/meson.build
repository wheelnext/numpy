source_root = meson.project_source_root()
mod_features = import('features')

if aarch64_variant != ''
  if aarch64_variant in ['8a', '8.1a']
    CPU_CONF_BASELINE = 'min'
    CPU_CONF_DISPATCH = ''
  elif aarch64_variant in ['8.2a', '8.3a', '8.4a', '8.5a', '9.0a']
    CPU_CONF_BASELINE = 'min'
    # 8.2-A introduces these instruction sets as "optional"
    CPU_CONF_DISPATCH = 'max'
  else
    error('Unknown aarch64 variant: ' + aarch64_variant)
  endif

  py = import('python').find_installation(pure: false)
  cc = meson.get_compiler('c')
  compiler_type = cc.get_argument_syntax()
  if compiler_type == ''
    compiler_type = cc.get_id()
  endif
  cpu_flags = run_command(
    py, 'get_cpu_flags.py', '--compiler-type', compiler_type, '--variant', aarch64_variant,
    capture: true,
    check: true,
  ).stdout().split()
  add_project_arguments(cpu_flags, language: ['c', 'cpp'])
endif

NEON = mod_features.new(
  'NEON', 1,
  test_code: files(source_root + '/numpy/distutils/checks/cpu_neon.c')[0]
)
NEON_FP16 = mod_features.new(
  'NEON_FP16', 2, implies: NEON,
  test_code: files(source_root + '/numpy/distutils/checks/cpu_neon_fp16.c')[0]
)
# FMA
NEON_VFPV4 = mod_features.new(
  'NEON_VFPV4', 3, implies: NEON_FP16,
  test_code: files(source_root + '/numpy/distutils/checks/cpu_neon_vfpv4.c')[0]
)
# Advanced SIMD
ASIMD = mod_features.new(
  'ASIMD', 4, implies: NEON_VFPV4, detect: {'val': 'ASIMD', 'match': 'NEON.*'},
  test_code: files(source_root + '/numpy/distutils/checks/cpu_asimd.c')[0]
)
cpu_family = host_machine.cpu_family()
if cpu_family == 'aarch64'
  # hardware baseline
  NEON.update(implies: [NEON_FP16, NEON_VFPV4, ASIMD])
  NEON_FP16.update(implies: [NEON, NEON_VFPV4, ASIMD])
  NEON_VFPV4.update(implies: [NEON, NEON_FP16, ASIMD])
elif cpu_family == 'arm'
  NEON.update(args: '-mfpu=neon')
  NEON_FP16.update(args: ['-mfp16-format=ieee', {'val': '-mfpu=neon-fp16', 'match': '-mfpu=.*'}])
  NEON_VFPV4.update(args: [{'val': '-mfpu=neon-vfpv4', 'match': '-mfpu=.*'}])
  ASIMD.update(args: [
    {'val': '-mfpu=neon-fp-armv8', 'match': '-mfpu=.*'},
    '-march=armv8-a+simd'
  ])
endif
# ARMv8.2 half-precision & vector arithm
ASIMDHP = mod_features.new(
  'ASIMDHP', 5, implies: ASIMD,
  args: {'val': '-march=armv8.2-a+fp16', 'match': '-march=.*', 'mfilter': '\+.*'},
  test_code: files(source_root + '/numpy/distutils/checks/cpu_asimdhp.c')[0]
)
## ARMv8.2 dot product
ASIMDDP = mod_features.new(
  'ASIMDDP', 6, implies: ASIMD,
  args: {'val': '-march=armv8.2-a+dotprod', 'match': '-march=.*', 'mfilter': '\+.*'},
  test_code: files(source_root + '/numpy/distutils/checks/cpu_asimddp.c')[0]
)
## ARMv8.2 Single & half-precision Multiply
ASIMDFHM = mod_features.new(
  'ASIMDFHM', 7, implies: ASIMDHP,
  args: {'val': '-march=armv8.2-a+fp16fml', 'match': '-march=.*', 'mfilter': '\+.*'},
  test_code: files(source_root + '/numpy/distutils/checks/cpu_asimdfhm.c')[0]
)
## Scalable Vector Extensions (SVE)
SVE = mod_features.new(
  'SVE', 8, implies: ASIMDHP,
  args: {'val': '-march=armv8.2-a+sve', 'match': '-march=.*', 'mfilter': '\+.*'},
  test_code: files(source_root + '/numpy/distutils/checks/cpu_sve.c')[0]
)
# TODO: Add support for MSVC
ARM_FEATURES = {
  'NEON': NEON, 'NEON_FP16': NEON_FP16, 'NEON_VFPV4': NEON_VFPV4,
  'ASIMD': ASIMD, 'ASIMDHP': ASIMDHP, 'ASIMDFHM': ASIMDFHM,
  'SVE': SVE
}
