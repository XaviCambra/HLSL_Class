//#define DEBUG_BLUR

using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class MotionBlurPostProcessing : PostProcessing
{
	Matrix4x4 m_PreviousViewMatrix;
	Matrix4x4 m_PreviousProjectionMatrix;
	bool m_PreviousMatricesInitalized=false;

	protected override void Start()
	{
		base.Start();
		m_PreviousMatricesInitalized=false;
	}
	protected override void InitHotValues()
	{
		base.InitHotValues();
	}
	protected override void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if(!m_PreviousMatricesInitalized)
		{
			m_PreviousMatricesInitalized=true;
			m_PreviousViewMatrix=m_Camera.worldToCameraMatrix;
			m_PreviousProjectionMatrix=m_Camera.projectionMatrix;
		}
		if(m_Material==null)
			return;
		base.InitHotValues();


#if DEBUG_BLUR
		transform.position-=Vector3.right*2.5f;
		m_PreviousViewMatrix=m_Camera.worldToCameraMatrix;
		transform.position+=Vector3.right*2.5f;
#endif

		m_Material.SetMatrix("_PreviousViewMatrix", m_PreviousViewMatrix);
		m_Material.SetMatrix("_PreviousProjectionMatrix", m_PreviousProjectionMatrix);
		m_Material.SetMatrix("_ViewMatrix", m_Camera.worldToCameraMatrix);
		m_Material.SetMatrix("_ProjectionMatrix", m_Camera.projectionMatrix);
		base.OnRenderImage(src, dest);
		m_PreviousViewMatrix=m_Camera.worldToCameraMatrix;
		m_PreviousProjectionMatrix=m_Camera.projectionMatrix;
    }
}
