from django.conf.urls import url
import voxel_globe.event_trigger.views as views

urlpatterns = [
  url(r'^event_trigger_results$', views.event_trigger_results, name='event_trigger_results'),
  url(r'^update_geometry_polygon$', views.update_geometry_polygon , name='update_geometry_polygon'),
  url(r'^get_event_geometry$', views.get_event_geometry, name='get_event_geometry'),
  url(r'^get_site_geometry$', views.get_site_geometry, name='get_site_geometry'),
  url(r'^run_event_trigger$', views.run_event_trigger, name='run_event_trigger'),
  url(r'^eventTriggerCreator/$', views.eventTriggerCreator, name='eventTriggerCreator'),
]