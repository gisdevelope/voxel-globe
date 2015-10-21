

def get_point_cloud(voxel_world_id, number_points=None, history=None):
  from voxel_globe.meta import models
  from vpgl_adaptor import convert_local_to_global_coordinates_array, create_lvcs
  import os
  import numpy as np
  from plyfile import PlyData

  voxel_world = models.VoxelWorld.objects.get(id=voxel_world_id).history(history)

  lvcs = create_lvcs(voxel_world.origin[1], voxel_world.origin[0], voxel_world.origin[2], 'wgs84')

  ply = PlyData.read(str(os.path.join(voxel_world.voxel_world_dir, 'model.ply')))
  data = ply.elements[0].data

  if number_points:
    try:
      import heapq
      data = np.array(heapq.nlargest(number_points, ply.elements[0].data, 
                                     key=lambda x:x['prob']))
    except IndexError: #not a correctly formated ply file. HACK A CODE!
      data = ply.elements[0].data.astype([('x', '<f4'), ('y', '<f4'), 
          ('z', '<f4'), ('red', 'u1'), ('green', 'u1'), ('blue', 'u1'), 
          ('prob', '<f4')])
      import copy
      blah = copy.deepcopy(data['y'])
      data['y'] = data['z']
      data['z'] = -blah
      blah = copy.deepcopy(data['blue'])
      data['blue'] = data['green']
      data['green'] = blah

      data['prob'] = abs(data['x'] - 10 - sum(data['x'])/len(data['x'])) \
                   + abs(data['y'] + 30 - sum(data['y'])/len(data['y'])) \
                   + abs(data['z'] - sum(data['z'])/len(data['z']))
      data['prob'] = max(data['prob']) - data['prob']

      data = np.array(heapq.nlargest(number_points, data, 
                                     key=lambda x:x['prob']))
      print data['prob']



  
  lla = convert_local_to_global_coordinates_array(lvcs, data['x'].tolist(), data['y'].tolist(), data['z'].tolist());

  latitude = np.array(lla[0])
  longitude = np.array(lla[1])
  altitude = np.array(lla[2])
  color = map(lambda r,b,g:'#%02x%02x%02x' % (r, g, b), data['red'], data['green'], data['blue'])
  return {"latitude": latitude,
          "longitude": longitude,
          "altitude": altitude,
          "color": color}
