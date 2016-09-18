def GenerateConfig(unused_context):
  resources = [{
      'name': context.env['name'],
      'type': 'compute.v1.network',
      'properties': {
          'autoCreateSubnetworks': True
      }
  }]
  return {'resources': resources}
